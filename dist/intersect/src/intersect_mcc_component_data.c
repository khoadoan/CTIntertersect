/*
 * MATLAB Compiler: 4.13 (R2010a)
 * Date: Wed Sep 19 21:01:12 2012
 * Arguments: "-B" "macro_default" "-o" "intersect" "-W" "main:intersect" "-T"
 * "link:exe" "-d" "/home/khoa/trmm-cs-local/operation/dist/intersect/src" "-w"
 * "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w"
 * "enable:demo_license" "-v"
 * "/home/khoa/trmm-cs-local/operation/matlab/intersect.m" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_intersect_session_key[] = {
    '0', '1', '4', '5', '6', 'F', '5', '7', 'C', '4', '2', 'E', 'E', '6', '1',
    'F', '8', '7', 'F', '8', 'A', '8', 'E', 'A', '4', 'A', 'A', 'B', 'E', 'A',
    'F', 'D', 'E', 'B', 'B', 'B', '5', 'A', '2', '4', '0', '4', '3', 'A', 'F',
    '2', 'D', '1', 'E', '4', 'B', '8', '0', '6', '5', '9', '8', 'E', '6', 'C',
    'C', '2', 'A', '8', 'E', 'D', 'E', '1', '5', '2', 'F', 'B', '7', '2', '4',
    'E', 'B', '7', '4', '7', '9', '1', '5', '7', '5', 'F', '1', '2', '1', '1',
    '2', 'A', 'D', 'C', 'E', '6', '6', 'E', '5', '4', 'A', 'C', '8', '5', '8',
    '3', 'B', 'F', 'C', 'A', '8', '2', 'F', '4', 'F', 'F', 'B', 'B', '4', '4',
    '8', '6', '4', '4', '4', '9', '7', '3', 'D', 'F', '2', 'B', 'F', 'A', 'C',
    '3', 'A', '6', 'E', 'A', '9', '7', '6', '2', '0', '9', 'D', 'A', 'E', 'F',
    'C', '6', '4', '4', 'D', '2', '4', 'C', 'F', '2', '7', '9', 'E', '5', 'B',
    '3', 'F', '0', '0', 'F', '7', 'E', 'E', '1', '0', '7', 'F', '3', '9', 'E',
    'E', 'E', '2', '0', '4', 'E', '7', 'F', 'F', '2', 'D', 'E', 'B', '0', 'C',
    'A', '5', 'D', 'B', 'E', 'C', '5', '7', '2', '0', 'F', '2', '9', '6', '6',
    '3', 'F', '8', 'E', '0', '3', '3', 'D', '2', 'E', '6', 'C', 'C', 'B', '0',
    'E', '5', 'D', '3', 'E', 'D', '4', '2', '7', '4', '0', '2', '0', 'F', '1',
    '2', '9', '5', '1', '4', '5', '8', '5', 'E', '8', '1', 'B', '3', 'F', '0',
    'B', '\0'};

const unsigned char __MCC_intersect_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_intersect_matlabpath_data[] = 
  { "intersect/", "$TOOLBOXDEPLOYDIR/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

static const char * MCC_intersect_classpath_data[] = 
  { "" };

static const char * MCC_intersect_libpath_data[] = 
  { "" };

static const char * MCC_intersect_app_opts_data[] = 
  { "" };

static const char * MCC_intersect_run_opts_data[] = 
  { "" };

static const char * MCC_intersect_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_intersect_component_data = { 

  /* Public key data */
  __MCC_intersect_public_key,

  /* Component name */
  "intersect",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_intersect_session_key,

  /* Component's MATLAB Path */
  MCC_intersect_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  37,

  /* Component's Java class path */
  MCC_intersect_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_intersect_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_intersect_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_intersect_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "intersect_A5A27901711176B9BAAC044766BE3F16",

  /* MCR warning status data */
  MCC_intersect_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


