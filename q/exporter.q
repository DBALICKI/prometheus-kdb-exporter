\l extract.q

// static info
infokeys:`release_date`release_version`os_version`process_cores`license_expiry_date
infovals:string[(.z.k;.z.K;.z.o;.z.c)],enlist .z.l 1

// metric classes
.prom.newmetric[`kdb_info;`info;infokeys;"process information"]
.prom.newmetric[`kdb_memory_usage_bytes;`gauge;();"memory allocated"]
.prom.newmetric[`kdb_memory_heap_bytes;`gauge;();"memory available in the heap"]
.prom.newmetric[`kdb_memory_heap_peak_bytes_total;`counter;();"maximum heap size so far"]
.prom.newmetric[`kdb_memory_heap_limit_bytes;`gauge;();"limit on thread heap size"]
.prom.newmetric[`kdb_memory_mapped_bytes;`gauge;();"mapped memory"]
.prom.newmetric[`kdb_memory_physical_bytes;`gauge;();"physical memory available"]
.prom.newmetric[`kdb_syms_total;`counter;();"number of symbols"]
.prom.newmetric[`kdb_syms_memory_bytes_total;`counter;();"memory use of symbols"]
.prom.newmetric[`kdb_ipc_opened_total;`counter;();"number of ipc sockets opened"]
.prom.newmetric[`kdb_ipc_closed_total;`counter;();"number of ipc sockets closed"]
.prom.newmetric[`kdb_ws_opened_total;`counter;();"number of websockets opened"]
.prom.newmetric[`kdb_ws_closed_total;`counter;();"number of websockets closed"]
.prom.newmetric[`kdb_handles;`gauge;();"number of open handles (ipc and websocket)"]
.prom.newmetric[`kdb_sync_total;`counter;();"number of sync requests"]
.prom.newmetric[`kdb_async_total;`counter;();"number of async requests"]
.prom.newmetric[`kdb_http_get_total;`counter;();"number of http get requests"]
.prom.newmetric[`kdb_http_post_total;`counter;();"number of http post requests"]
.prom.newmetric[`kdb_ws_total;`counter;();"number of websocket messages"]
.prom.newmetric[`kdb_ts_total;`counter;();"number of timer calls"]
.prom.newmetric[`kdb_sync_err_total;`counter;();"number of errors from sync requests"]
.prom.newmetric[`kdb_async_err_total;`counter;();"number of errors from async requests"]
.prom.newmetric[`kdb_http_get_err_total;`counter;();"number of errors from http get requests"]
.prom.newmetric[`kdb_http_post_err_total;`counter;();"number of errors from http post requests"]
.prom.newmetric[`kdb_ws_err_total;`counter;();"number of errors from websocket messages"]
.prom.newmetric[`kdb_ts_err_total;`counter;();"number of errors from timer calls"]
.prom.newmetric[`kdb_sync_seconds;`histogram;();"duration of sync requests"]
.prom.newmetric[`kdb_async_seconds;`histogram;();"duration of async requests"]
.prom.newmetric[`kdb_http_get_seconds;`histogram;();"duration of http get requests"]
.prom.newmetric[`kdb_http_post_seconds;`histogram;();"duration of http post requests"]
.prom.newmetric[`kdb_ws_seconds;`histogram;();"duration of websocket messages"]
.prom.newmetric[`kdb_ts_seconds;`histogram;();"duration of timer calls"]

// metric instances
info      :.prom.addmetric[`kdb_info;infovals;()]
mem       :.prom.addmetric[`kdb_memory_usage_bytes;();()]
mem_heap  :.prom.addmetric[`kdb_memory_heap_bytes;();()]
mem_lim   :.prom.addmetric[`kdb_memory_heap_peak_bytes_total;();()]
mem_max   :.prom.addmetric[`kdb_memory_heap_limit_bytes;();()]
mem_map   :.prom.addmetric[`kdb_memory_mapped_bytes;();()]
mem_phys  :.prom.addmetric[`kdb_memory_physical_bytes;();()]
sym_num   :.prom.addmetric[`kdb_syms_total;();()]
sym_mem   :.prom.addmetric[`kdb_syms_memory_bytes_total;();()]
ipc_opened:.prom.addmetric[`kdb_ipc_opened_total;();()]
ipc_closed:.prom.addmetric[`kdb_ipc_closed_total;();()]
ws_opened :.prom.addmetric[`kdb_ws_opened_total;();()]
ws_closed :.prom.addmetric[`kdb_ws_closed_total;();()]
hdl_open  :.prom.addmetric[`kdb_handles;();()]
qry_sync  :.prom.addmetric[`kdb_sync_total;();()]
qry_async :.prom.addmetric[`kdb_async_total;();()]
qry_http  :.prom.addmetric[`kdb_http_get_total;();()]
qry_post  :.prom.addmetric[`kdb_http_post_total;();()]
qry_ws    :.prom.addmetric[`kdb_ws_total;();()]
qry_ts    :.prom.addmetric[`kdb_ts_total;();()]
err_sync  :.prom.addmetric[`kdb_sync_err_total;();()]
err_async :.prom.addmetric[`kdb_async_err_total;();()]
err_http  :.prom.addmetric[`kdb_http_get_err_total;();()]
err_post  :.prom.addmetric[`kdb_http_post_err_total;();()]
err_ws    :.prom.addmetric[`kdb_ws_err_total;();()]
err_ts    :.prom.addmetric[`kdb_ts_err_total;();()]
hist_sync :.prom.addmetric[`kdb_sync_seconds;();.prom.default_histogram_bins]
hist_async:.prom.addmetric[`kdb_async_seconds;();.prom.default_histogram_bins]
hist_http :.prom.addmetric[`kdb_http_get_seconds;();.prom.default_histogram_bins]
hist_post :.prom.addmetric[`kdb_http_post_seconds;();.prom.default_histogram_bins]
hist_ws   :.prom.addmetric[`kdb_ws_seconds;();.prom.default_histogram_bins]
hist_ts   :.prom.addmetric[`kdb_ts_seconds;();.prom.default_histogram_bins]

// memory metrics (.Q.w[])
memmetrics:value each`mem`mem_heap`mem_lim`mem_max`mem_map`mem_phys`sym_num`sym_mem

// define logic to run in event handlers
.prom.on_poll:{[msg].prom.updval[;:;]'[memmetrics;value"f"$.Q.w[]];}

.prom.on_po:{[msg]
  .prom.inc_counter[ipc_opened;1];
  .prom.set_gauge[hdl_open;"f"$count .z.W];}
.prom.on_pc:{[msg]
  .prom.inc_counter[ipc_closed;1];
  .prom.set_gauge[hdl_open;"f"$count .z.W];}
.prom.on_wo:{[msg]
  .prom.inc_counter[ws_opened;1];
  .prom.set_gauge[hdl_open;"f"$count .z.W];}
.prom.on_wc:{[msg]
  .prom.inc_counter[ws_closed;1];
  .prom.set_gauge[hdl_open;"f"$count .z.W];}
before:{[met;msg]
  .prom.inc_counter[value`$"qry_",met;1];
  .prom.updval[value`$"err_",met;+;1];
  .z.p}
after:{[met;tmp;msg;res]
  .prom.updval[value`$"err_",met;-;1];
  tm:(10e-10)*.z.p-tmp;
  .prom.observe_histogram[value`$"hist_",met;tm];}
.prom.before_pg:before"sync"
.prom.after_pg :after"sync"
.prom.before_ps:before"async"
.prom.after_ps :after"async"
.prom.before_ph:before"http"
.prom.after_ph :after"http"
.prom.before_pp:before"post"
.prom.after_pp :after"post"
.prom.before_ws:before"ws"
.prom.after_ws :after"ws"
.prom.before_ts:before"ts"
.prom.after_ts :after"ts"
