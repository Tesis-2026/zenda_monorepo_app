# Registro previo a correccion de validacion

Fecha: 2026-09-13. Base backend: 98bcd2c.

- Instrumentos (preguntas, opciones, claves): no se modifican.
- SHA256 previo de prisma/seed.ts: 7D1B04BABBB8AC883DD8358E47B9F6F1B94E706D7E2B84122B7E50E3D5F65855.
- SHA256 previo del controlador surveys: A284EE0F801C37E503F078AE0FF2C129EA27D55E1BB63173BA9C3A87220A443A.
- Scoring anterior: SUS usa Math.round(sum * 2.5), admite cuestionarios incompletos estructuralmente y valores como 5abc; PRE/POST acepta respuestas vacias.
- Scoring nuevo, identificador `survey-validation-2026-09-13`: SUS conserva incrementos de 2.5, exige diez items ordenados 1..10; escala estricta; PRE/POST exige respuestas del instrumento.
- No recalcular respuestas existentes ni comparar cohortes sin registrar esta diferencia. Confirmar con asesoria academica instrumento y umbrales; etiquetas de usabilidad existentes no se consideran validadas.
- Prompts, modelo y corpus: no alterados en esta auditoria. El manifiesto generado registra hashes locales, no presupone la version remota.
