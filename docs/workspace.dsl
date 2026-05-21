workspace "Zenda" "Personal finance app for university students in Lima" {

    !identifiers hierarchical

    model {
        student = person "University Student" "18-24 year olds in Lima using Android 9.0+"

        ai = softwareSystem "Azure AI Foundry" "AI platform for financial intelligence" "External"
        email = softwareSystem "Email Provider" "Delivers transactional emails to users" "External"
        fcm = softwareSystem "Firebase Cloud Messaging" "Push notification delivery service" "External"

        zenda = softwareSystem "Zenda System" "Helps students track spending, view reports, and complete financial challenges" {

            mobile = container "Mobile App" "Records transactions, views reports, completes challenges, chats with AI assistant" "Flutter · Android 9.0+" "Mobile"

            api = container "Zenda API" "REST endpoints; JWT auth; Swagger UI at /api/docs. 10 bounded contexts: auth, users, transactions, categories, budgets, goals, insights, predictions, recommendations, education." "NestJS 11" {

                # ── Core modules ──────────────────────────────────────────────
                authModule = component "Auth Module" "Register, login, JWT refresh, logout, forgot-password, OTP verify, reset-password. Lockout after 3 failed attempts." "NestJS Module"
                usersModule = component "Users Module" "GET/PUT /users/me — profile read and update. Also manages push notification preferences. Profile fields feed AI context." "NestJS Module"
                transactionsModule = component "Transactions Module" "CRUD /transactions. POST /transactions/classify auto-categorises by description + amount via AI. Spending anomaly check (>20% over 3-month average) runs on every create." "NestJS Module"
                categoriesModule = component "Categories Module" "System + custom categories CRUD." "NestJS Module"
                budgetsModule = component "Budgets Module" "Monthly budgets per category with current-spend tracking." "NestJS Module"
                goalsModule = component "Goals Module" "Savings goals with contribute and complete endpoints." "NestJS Module"
                insightsModule = component "Insights Module" "Day / week / month summaries, multi-month comparison, PDF report export." "NestJS Module"

                # ── AI-powered modules ────────────────────────────────────────
                predictionsModule = component "Predictions Module" "GET /predictions/expenses — builds SpendingContext from transaction history, sends to AI, returns predicted totals per category + confidence level + Spanish narrative. Falls back to weighted 3-month moving average." "NestJS Module"
                recommendationsModule = component "Recommendations Module" "GET /recommendations and POST /ai/chat — AI-generated SAVINGS | BUDGET | GOAL recommendations plus conversational financial assistant. Also tracks accept/reject feedback on recommendations." "NestJS Module"
                educationModule = component "Education Module" "Topics, quizzes, challenges, badges, research surveys, and GET /education/quiz/personalized — AI-generated questions capped at 5 per user per day. Tracks in-app feedback submissions." "NestJS Module"

                # ── Infra ─────────────────────────────────────────────────────
                aiProvider = component "AzureFoundryProvider" "Wraps Azure OpenAI Chat Completions. 5 methods: predictExpenses, generateRecommendations, classifyTransaction, chat, generatePersonalizedQuiz. Graceful fallback to LocalRulesProvider when not configured." "Infrastructure"
                emailService = component "EmailService" "Nodemailer wrapper — sendPasswordResetEmail, sendOtpEmail." "Infrastructure"
                spendingAlert = component "SpendingAlertService" "Compares current-month category spending against 3-month rolling average; flags anomalies >20% over." "Infrastructure"
            }

            db = container "Database" "Users, transactions, categories, budgets, goals, insights, challenges, badges, analytics events, notification preferences" "PostgreSQL 15" "Database"
        }

        # ── Context-level relationships ───────────────────────────────────────
        student -> zenda "Manages personal finances"
        zenda -> ai "Requests AI-powered insights"
        zenda -> email "Sends transactional emails"
        zenda -> fcm "Triggers push notifications"
        fcm -> student "Delivers push notifications"

        # ── Container-level relationships ─────────────────────────────────────
        student -> zenda.mobile "Uses" "Android"
        zenda.mobile -> zenda.api "Makes API calls to" "HTTPS / REST + JWT"
        zenda.api -> zenda.db "Reads from and writes to" "Prisma ORM"
        zenda.api -> ai "5 AI calls" "JSON / HTTPS"
        zenda.api -> email "Sends transactional emails" "SMTP"
        zenda.api -> fcm "Dispatches push notification events" "HTTPS"

        # ── Component-level AI flows ──────────────────────────────────────────
        zenda.api.predictionsModule -> zenda.api.aiProvider "predictExpenses(SpendingContext) → {predictedTotal, predictedByCategory[], confidenceLevel, narrative}"
        zenda.api.recommendationsModule -> zenda.api.aiProvider "generateRecommendations(SpendingContext) → [{type, message, suggestedAction}]"
        zenda.api.recommendationsModule -> zenda.api.aiProvider "chat(messages[], userProfile) → string"
        zenda.api.transactionsModule -> zenda.api.aiProvider "classifyTransaction(description, amount) → {categoryName, confidence}"
        zenda.api.educationModule -> zenda.api.aiProvider "generatePersonalizedQuiz(SpendingContext, language) → {questions[]}"

        zenda.api.aiProvider -> ai "Azure OpenAI Chat Completions — JSON prompts in Spanish, response_format: json_object, temperature: 0.3 (0.5 for chat)" "JSON / HTTPS"

        # ── Component → Database ──────────────────────────────────────────────
        zenda.api.authModule -> zenda.db "Reads/writes users, refresh tokens, OTP records" "Prisma ORM"
        zenda.api.usersModule -> zenda.db "Reads/writes user profiles and notification preferences" "Prisma ORM"
        zenda.api.transactionsModule -> zenda.db "Reads/writes transactions and analytics events" "Prisma ORM"
        zenda.api.categoriesModule -> zenda.db "Reads/writes categories" "Prisma ORM"
        zenda.api.budgetsModule -> zenda.db "Reads/writes budgets" "Prisma ORM"
        zenda.api.goalsModule -> zenda.db "Reads/writes goals, contributions, and analytics events" "Prisma ORM"
        zenda.api.insightsModule -> zenda.db "Reads transactions for aggregation" "Prisma ORM"
        zenda.api.predictionsModule -> zenda.db "Reads transaction history to build SpendingContext; writes analytics events" "Prisma ORM"
        zenda.api.recommendationsModule -> zenda.db "Reads/writes recommendations, feedback, and analytics events" "Prisma ORM"
        zenda.api.educationModule -> zenda.db "Reads/writes topics, quizzes, challenges, badges, surveys, feedback, and analytics events" "Prisma ORM"

        # ── Other component relationships ─────────────────────────────────────
        zenda.api.authModule -> zenda.api.emailService "Triggers password-reset and OTP emails"
        zenda.api.emailService -> email "Sends via SMTP"
        zenda.api.transactionsModule -> zenda.api.spendingAlert "Checks anomaly on every transaction create"
        zenda.api.educationModule -> zenda.api.transactionsModule "Reads transaction history to verify challenge completion"

        # ── Deployment ────────────────────────────────────────────────────────
        live = deploymentEnvironment "Production" {
            azure = deploymentNode "Azure Cloud" {
                apiNode = deploymentNode "App Service" {
                    containerInstance zenda.api
                }
                dbNode = deploymentNode "Azure Database for PostgreSQL" {
                    containerInstance zenda.db
                }
            }
            phone = deploymentNode "User's Android Device" "Android 9.0+" {
                containerInstance zenda.mobile
            }
        }
    }

    views {
        systemContext zenda "Context" {
            include student
            include zenda
            include ai
            include email
            include fcm
            autolayout lr
        }

        container zenda "Containers" {
            include *
            autolayout lr
        }

        component zenda.api "Components" {
            include *
            autolayout tb
        }

        deployment zenda live "ProductionDeployment" {
            include *
            autolayout lr
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Mobile" {
                shape MobileDevicePortrait
            }
            element "Database" {
                shape cylinder
            }
        }

        theme default
    }
}
