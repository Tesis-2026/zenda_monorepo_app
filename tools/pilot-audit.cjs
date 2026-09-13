const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { execFileSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const back = path.join(root, 'zenda_backend_app');
const front = path.join(root, 'zenda_fronted_app');
const out = path.join(root, 'docs/pilot-readiness');
const ts = require(path.join(back, 'node_modules/typescript'));
const { Prisma } = require(path.join(back, 'node_modules/@prisma/client'));
const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(path.join(dir,e.name)) : [path.join(dir,e.name)]);
const relative = p => path.relative(root,p).replaceAll('\\','/');
const read = p => fs.readFileSync(p,'utf8');
const hash = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const write = (file,text) => fs.writeFileSync(path.join(out,file),text+'\n');
const git = (cwd,...args) => execFileSync('git',args,{cwd,encoding:'utf8'}).trim();
const cell = s => String(s ?? '').replaceAll('|','&#124;').replace(/\r?\n/g,'<br>');
const table = (headers,rows) => ['| '+headers.join(' | ')+' |','| '+headers.map(()=> '---').join(' | ')+' |',...rows.map(r=>'| '+r.map(cell).join(' | ')+' |')].join('\n');
fs.mkdirSync(out,{recursive:true});
const endpoints=[],dtos=[],sources=walk(path.join(back,'src')).filter(p=>p.endsWith('.ts'));
const decorators = node => ts.canHaveDecorators(node) ? ts.getDecorators(node) ?? [] : [];
const dec = node => decorators(node).map(d => {
  const c=d.expression;
  return {name:ts.isCallExpression(c)?c.expression.getText():c.getText(),args:ts.isCallExpression(c)?c.arguments:[]};
});
for(const file of sources) {
  const ast=ts.createSourceFile(file,read(file),ts.ScriptTarget.Latest,true);
  for(const cls of ast.statements.filter(ts.isClassDeclaration)) {
    const prefix=dec(cls).find(d=>d.name==='Controller');
    const literal = a => a && ts.isStringLiteral(a) ? a.text : '';
    for(const m of cls.members) {
      const route=dec(m).find(d=>['Get','Post','Put','Patch','Delete'].includes(d.name));
      if(prefix && route) endpoints.push({method:route.name.toUpperCase(),path:'/api/'+[literal(prefix.args[0]),literal(route.args[0])].filter(Boolean).join('/'),handler:cls.name.text+'.'+m.name.getText(),parameters:m.parameters.map(p=>({name:p.name.getText(),type:p.type?.getText()??'inferred',decorators:dec(p).map(d=>d.name)})),returns:m.type?.getText()??'inferred',guards:dec(cls).filter(d=>d.name==='UseGuards').flatMap(d=>d.args.map(a=>a.getText())),file:relative(file),line:ast.getLineAndCharacterOfPosition(m.getStart()).line+1});
    }
    if(file.includes(`${path.sep}dto${path.sep}`)) dtos.push({name:cls.name?.text,file:relative(file),fields:cls.members.filter(ts.isPropertyDeclaration).map(m=>({name:m.name.getText(),type:m.type?.getText()??'inferred',optional:!!m.questionToken,validators:dec(m).filter(d=>!d.name.startsWith('Api')).map(d=>d.name)}))});
  }
}
write('api-inventory.json',JSON.stringify({baseCommit:git(back,'rev-parse','HEAD'),endpoints,dtos,datamodel:Prisma.dmmf.datamodel},null,2));
write('API_INVENTORY.md','# Inventario AST de rutas y DTO\n\nGenerado sin arrancar la app ni leer secretos. Guards globales, pipes e interceptores se revisan por separado. `inferred` requiere leer el mapper/servicio.\n\n'+table(['Metodo','Ruta','Handler','Entrada','Salida','Archivo:linea'],endpoints.map(e=>[e.method,e.path,e.handler,e.parameters.map(p=>p.decorators.join('+')+' '+p.type).join('; '),e.returns,e.file+':'+e.line]))+'\n\n## DTO\n\n'+table(['DTO','Campo','Tipo','Opcional TS','Validadores','Archivo'],dtos.flatMap(d=>d.fields.map(f=>[d.name,f.name,f.type,f.optional,f.validators.join(', '),d.file])))+'\n\n## Entidades y relaciones\n\n'+table(['Entidad','Campo','Tipo','Lista','Requerido','Relacion'],Prisma.dmmf.datamodel.models.flatMap(m=>m.fields.map(f=>[m.name,f.name,f.type,f.isList,f.isRequired,f.relationName??'']))));

const groups = [
  {ids:[1,2,3,4,12,39],module:'transactions',screens:['add_transaction_screen.dart','edit_transaction_screen.dart','transaction_list_screen.dart'],tables:'Transaction, Category, Account, IdempotencyKey',metric:'transaction_created; task_completed'},
  {ids:[5,6,18,40,41],module:'categories',screens:['add_transaction_screen.dart','edit_transaction_screen.dart','categories_screen.dart'],tables:'Category, Transaction',metric:'classify_transaction; task_completed'},
  {ids:[7,8,9,10,11,13,14,38],module:'insights',screens:['reports_screen.dart','dashboard_screen.dart'],tables:'Transaction, SavingsGoal',metric:'screen_view; task_completed'},
  {ids:[15],module:'predictions',screens:['predictions_screen.dart'],tables:'Prediction, Transaction',metric:'view_prediction; latency_ms'},
  {ids:[16],module:'transactions',screens:['add_transaction_screen.dart','notifications_inbox_screen.dart'],tables:'Transaction, Notification',metric:'record_transaction; latency_ms'},
  {ids:[17],module:'recommendations',screens:['recommendations_screen.dart'],tables:'Recommendation, Transaction, SavingsGoal',metric:'task_completed; latency_ms'},
  {ids:[19,20,42,43],module:'budgets',screens:['budget_screen.dart'],tables:'Budget, Transaction, Notification',metric:'create_budget; task_completed'},
  {ids:[21,22,44,45],module:'goals',screens:['goals_screen.dart','goal_detail_screen.dart'],tables:'SavingsGoal, GoalContribution',metric:'create_goal; contribute_goal'},
  {ids:[23,26,48,49],module:'education',screens:['education_screen.dart','quiz_screen.dart'],tables:'EducationalTopic, QuizQuestion, QuizAttempt, UserTopicProgress',metric:'view_topic; submit_quiz'},
  {ids:[24,46],module:'challenges',screens:['education_screen.dart'],tables:'Challenge, UserChallenge',metric:'accept_challenge; complete_challenge'},
  {ids:[25],module:'badges',screens:['badges_screen.dart'],tables:'Badge, UserBadge',metric:'task_completed'},
  {ids:[27,28,29],module:'auth',screens:['login_screen.dart','register_screen.dart'],tables:'User, RefreshToken, AuthChallenge, AuditLog',metric:'login; register_email_verified'},
  {ids:[30,31,32],module:'users',screens:['profile_screen.dart','profile_setup_screen.dart','onboarding_screen.dart'],tables:'User',metric:'screen_view; task_completed'},
  {ids:[33,34,35,47],module:'surveys',screens:['pre_survey_screen.dart','sus_screen.dart','dashboard_screen.dart'],tables:'Survey, SurveyResponse, User',metric:'sus_submitted; paired_pre_post'},
  {ids:[36],module:'feedback',screens:['feedback_modal.dart'],tables:'Feedback',metric:'submit_feedback'},
  {ids:[37],module:'research-dashboard',screens:['app.dart'],tables:'AnalyticsEvent, SurveyResponse, AiMessageFeedback',metric:'app_session_started; task_abandoned'},
];
const gaps={3:'Editor conserva ID al no cambiar categoria; falta selector completo de personalizadas.',5:'Catalogo por tipo; faltan pruebas de idioma y duplicado en dispositivo.',6:'Lista enum y catalogo remoto coexisten; no declarar fuente unica.',11:'API compara N meses consecutivos; HU pide escoger al menos dos meses concretos.',13:'PDF implementado; graficos, exportacion vacia y compartir no verificados.',15:'Estimacion heuristica/RAG, no modelo entrenado ni probabilidad calibrada; umbral 60% sin evidencia.',16:'Explicacion agente complementa estadistica; latencia/notificacion real pendientes.',18:'Precision >80% no medida; no equiparar heuristica con RAG.',19:'Asignacion por budgetId opcional no es acumulacion automatica de categoria.',20:'Alerta depende de presupuesto vinculado; duplicados/canal FCM pendientes.',26:'Feedback final no inmediato por pregunta; SubmitQuiz no persiste intentos.',27:'Requisito inicio automatico contradice OTP obligatorio actual. Mantener OTP.',29:'TLS/backups no verificados; borrado no anonimiza textos historicos; consentimiento investigacion separado pendiente.',31:'Selector monetario no implica conversion de divisas; saldos multimoneda requieren decision.',33:'PRE depende de seed; perfil y respuesta no transaccionales.',34:'30 dias desde createdAt no equivale a 30 dias activos.',35:'SUS matematico corregido; elegibilidad por 3 dias/sesiones no final del piloto.',37:'Seudonimizacion no anonimato; faltan colas/eventos de abandono y consentimiento separado.',38:'Resumen backend topCategories solo gastos; ingresos dependen de lista paginada frontend.',40:'Catalogo remoto no es unico en todos los editores.',41:'Soft delete difiere de bloquear categoria usada segun criterio.',42:'Limites vinculados; comprobar no sumar transferencias ni periodos ajenos.',44:'Incremento y aporte atomicos; falta estres con PostgreSQL real.',45:'Completar no inventa saldo; eliminacion logica conserva aportes, diferente al criterio literal.',47:'Validacion estricta; instrumento y equivalencia pre/post no aprobados academicamente.',48:'Orden/rationale generados con fallback; sin evaluacion humana de pertinencia.',49:'Preguntas personalizadas sin propietario/intento persistido; no aptas como pre/post.'};
const frontendFiles=walk(path.join(front,'lib'));
const testFiles=walk(path.join(back,'test')).filter(p=>p.endsWith('.e2e-spec.ts'));
const huLines=read(path.join(root,'docs/Zenda_Backlog_HU_Validacion_Codex.md')).split(/\r?\n/).filter(l=>/^\| HU-\d{3}\s*\|/.test(l));
if(huLines.length!==49) throw Error('Expected 49 HU');
const rows=huLines.map(line=>{
  const cols=line.split('|').map(s=>s.trim()); const id=Number(cols[1].slice(3)); const g=groups.find(g=>g.ids.includes(id));
  if(!g) throw Error('Missing mapping '+id);
  const routes=endpoints.filter(e=>e.file.includes('/modules/'+g.module+'/'));
  const screenFiles=g.screens.map(name=>frontendFiles.find(p=>path.basename(p)===name)).filter(Boolean).map(relative);
  const tests=testFiles.filter(p=>path.basename(p).includes(g.module)).map(relative);
  return [cols[1],cols[2].split('<br>')[0],cols[3],screenFiles.join('<br>')||'No se pudo localizar pantalla por nombre; revisar lib/features/'+g.module,'Ejecutar ambos escenarios del criterio; guion 10',routes.map(e=>e.method+' '+e.path).join('<br>'),[...new Set(routes.flatMap(e=>e.parameters.map(p=>p.type)))].join('; '),routes.map(e=>e.handler).join('; '),g.tables,tests.join('<br>')||'Sin suite dedicada; guion manual pendiente',g.metric,(gaps[id]?'Parcial':'Implementado sin pruebas')+': '+(gaps[id]||'Existe flujo y/o contrato mock, no ejecutados todos los criterios ni SLA extremo a extremo.')];
});
write('02_HU_TRACEABILITY_MATRIX.md','# Trazabilidad HU al estado auditado\n\n49 HU; 0 certificadas completas extremo a extremo; 49 pendientes de aceptacion integral; 0 totalmente ausentes. "Implementado sin pruebas" significa SIN prueba completa de sus criterios, aunque existan contratos mock. No se hereda el "Realizado" del informe anterior.\n\n'+table(['HU','Descripcion','Criterio original completo','Pantalla Flutter','Accion','Endpoint','DTO/entrada','Servicio/handler','Entidad','Prueba','Metrica','Estado y brecha'],rows)+'\n\nVoz, OCR, cuentas y chat son capacidades adicionales fuera de las 49 HU originales: ver contratos y QA. Tiempos <2/<3/<5/<10 segundos de los criterios permanecen SIN medir en dispositivo.');
const trackedSources=[...sources.filter(p=>/azure-foundry-agent|financial-context|personalized.*use-case|surveys.*controller/.test(p)),path.join(back,'prisma/seed.ts'),path.join(back,'prisma/schema.prisma'),path.join(back,'package-lock.json'),path.join(front,'pubspec.lock')];
const migrations=walk(path.join(back,'prisma/migrations')).filter(p=>p.endsWith('.sql'));
write('version-manifest.json',JSON.stringify({generatedAt:new Date().toISOString(),repos:[root,back,front].map(p=>({repo:path.basename(p),branch:git(p,'branch','--show-current'),baseCommit:git(p,'rev-parse','HEAD'),dirty:!!git(p,'status','--porcelain')})),files:[...trackedSources,...migrations].map(p=>({file:relative(p),sha256:hash(p)})),remoteAgent:{model:null,modelVersion:null,temperature:null,topP:null,embeddings:null,index:null,documentCount:null,reason:'Remote configuration not inspected; do not infer from agent name'},instrumentVersion:'survey-validation-2026-09-13'},null,2));
const changes=[back,front].flatMap(p=>{const status=git(p,'status','--porcelain').split(/\r?\n/).filter(Boolean); return status.map(line=>[path.basename(p),line.slice(0,2).trim(),line.slice(3)]);});
write('CHANGED_FILES.md','# Archivos modificados\n\nGenerado de git status. No incluye secretos ni sus valores. Nuevos directorios se expanden en el diff de revision.\n\n'+table(['Repo','Estado','Archivo'],changes));
console.log(JSON.stringify({endpoints:endpoints.length,dtos:dtos.length,models:Prisma.dmmf.datamodel.models.length,histories:rows.length,migrations:migrations.length}));
