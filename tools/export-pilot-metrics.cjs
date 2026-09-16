// Offline export from an access-controlled, consent-filtered event extract.
// Never feed operational exports into Git. No database or network access here.
const fs=require('node:fs');
const crypto=require('node:crypto');
const allowed=new Set(['app_session_started','app_session_ended','task_started','task_completed','task_abandoned','functional_error','record_transaction','transaction_created','view_report','create_budget','receipt_analyzed','ocr_field_corrected','chat_message_sent','quiz_started','submit_quiz','help_requested','endpoint_completed','ai_completed','app_crashed','screen_view']);
function exportRows(rows,key) {
  if(typeof key!=='string'||key.length<32) throw Error('PILOT_PSEUDONYM_KEY must have at least 32 characters');
  return rows.filter(r=>r.consentGiven===true && !r.deletedAt && allowed.has(r.eventType) && typeof r.userId==='string').map(r=>{
    const created=new Date(r.createdAt); if(Number.isNaN(created.getTime())) throw Error('Invalid timestamp');
    const n=r.metadata?.duration_ms ?? r.metadata?.latency_ms;
    return {participant_id:crypto.createHmac('sha256',key).update(r.userId).digest('hex'),event_type:r.eventType,created_at:created.toISOString(),duration_ms:typeof n==='number'&&Number.isFinite(n)&&n>=0&&n<=86400000?n:null,schema_version:'pilot-metrics-1'};
  });
}
if(require.main===module) {
  const [input,prefix]=process.argv.slice(2);
  if(!input||!prefix) throw Error('Usage: node tools/export-pilot-metrics.cjs PRIVATE_INPUT.json PRIVATE_OUTPUT_PREFIX');
  const rows=exportRows(JSON.parse(fs.readFileSync(input,'utf8')),process.env.PILOT_PSEUDONYM_KEY);
  fs.writeFileSync(prefix+'.json',JSON.stringify(rows,null,2),{flag:'wx'});
  const keys=['participant_id','event_type','created_at','duration_ms','schema_version'];
  fs.writeFileSync(prefix+'.csv',[keys.join(','),...rows.map(r=>keys.map(k=>JSON.stringify(r[k]??'')).join(','))].join('\n'),{flag:'wx'});
  console.log(JSON.stringify({exported:rows.length,containsDirectIdentifiers:false}));
}
module.exports={exportRows};
