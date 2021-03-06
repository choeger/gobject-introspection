#cmph
include_directories(girepository/cmph/ ${GLIB_INCLUDE_DIR} ${GLIB_CONFIG_INCLUDE_DIR})
set(cmph_sources "girepository/cmph/bdz.c"
	"girepository/cmph/bdz.h"
	"girepository/cmph/bdz_ph.c"
	"girepository/cmph/bdz_ph.h"
	"girepository/cmph/bdz_structs.h"
	"girepository/cmph/bdz_structs_ph.h"
	"girepository/cmph/bitbool.h"
	"girepository/cmph/bmz8.c"
	"girepository/cmph/bmz8.h"
	"girepository/cmph/bmz8_structs.h"
	"girepository/cmph/bmz.c"
	"girepository/cmph/bmz.h"
	"girepository/cmph/bmz_structs.h"
	"girepository/cmph/brz.c"
	"girepository/cmph/brz.h"
	"girepository/cmph/brz_structs.h"
	"girepository/cmph/buffer_entry.c"
	"girepository/cmph/buffer_entry.h"
	"girepository/cmph/buffer_manager.c"
	"girepository/cmph/buffer_manager.h"
	"girepository/cmph/chd.c"
	"girepository/cmph/chd.h"
	"girepository/cmph/chd_ph.c"
	"girepository/cmph/chd_ph.h"
	"girepository/cmph/chd_structs.h"
	"girepository/cmph/chd_structs_ph.h"
	"girepository/cmph/chm.c"
	"girepository/cmph/chm.h"
	"girepository/cmph/chm_structs.h"
	"girepository/cmph/cmph.c"
	"girepository/cmph/cmph.h"
	"girepository/cmph/cmph_structs.c"
	"girepository/cmph/cmph_structs.h"
	"girepository/cmph/cmph_time.h"
	"girepository/cmph/cmph_types.h"
	"girepository/cmph/compressed_rank.c"
	"girepository/cmph/compressed_rank.h"
	"girepository/cmph/compressed_seq.c"
	"girepository/cmph/compressed_seq.h"
	"girepository/cmph/debug.h"
	"girepository/cmph/fch_buckets.c"
	"girepository/cmph/fch_buckets.h"
	"girepository/cmph/fch.c"
	"girepository/cmph/fch.h"
	"girepository/cmph/fch_structs.h"
	"girepository/cmph/graph.c"
	"girepository/cmph/graph.h"
	"girepository/cmph/hash.c"
	"girepository/cmph/hash.h"
	"girepository/cmph/hash_state.h"
	"girepository/cmph/jenkins_hash.c"
	"girepository/cmph/jenkins_hash.h"
	"girepository/cmph/miller_rabin.c"
	"girepository/cmph/miller_rabin.h"
	"girepository/cmph/select.c"
	"girepository/cmph/select.h"
	"girepository/cmph/select_lookup_tables.h"
	"girepository/cmph/vqueue.c"
	"girepository/cmph/vqueue.h"
	"girepository/cmph/vstack.c"
	"girepository/cmph/vstack.h")
add_library(cmph SHARED ${cmph_sources})

install(TARGETS cmph
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION "include/${girepodir}"
)
