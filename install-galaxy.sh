cd "$(dirname "$0")"
# Install Galaxy
if [[ ! -e galaxy ]]; then
    git clone git@github.com:galaxyproject/galaxy.git
fi

cd galaxy
git checkout release_19.09


# Add job rules
(
umask 077
cat > "./lib/galaxy/jobs/rules/destinations.py" << EOL
import logging
from galaxy.jobs.mapper import JobMappingException
from galaxy.jobs import JobDestination

log = logging.getLogger(__name__)

FAILURE_MESSAGE = 'This tool could not be run because of a misconfiguration in the Galaxy job running system, please report this error'


def dynamic_cores_time(app, tool, job, user_email, resource_params):
    # handle job resource parameters
    if not resource_params.get("cores") and not resource_params.get("time"):
        default_destination_id = app.job_config.get_destination(None)
        log.warning('(%s) has no input parameter cores or time. Run with default runner: %s' % (job.id, default_destination_id.runner))
        return default_destination_id
    
    try:
        cores = resource_params.get("cores")
        time = resource_params.get("time")
        resource_list = 'walltime=%s:00:00,nodes=1:ppn=%s' % (time, cores)
    except:
        default_destination_id = app.job_config.get_destination(None)
        log.warning('(%s) failed to run with customized configuration. Run with default runner: %s' % (job.id, default_destination_id.runner))
        return default_destination_id

    log.info('returning pbs runner with configuration %s', resource_list)
    return JobDestination(runner="pbs", params={"Resource_List": resource_list})
EOL
)

# Install dependencies
# Retrieved from line 1-54 in https://github.com/galaxyproject/galaxy/blob/release_19.09/run.sh
. ./scripts/common_startup_functions.sh

# If there is a file that defines a shell environment specific to this
# instance of Galaxy, source the file.
if [ -z "$GALAXY_LOCAL_ENV_FILE" ];
then
    GALAXY_LOCAL_ENV_FILE='./config/local_env.sh'
fi

if [ -f "$GALAXY_LOCAL_ENV_FILE" ];
then
    . "$GALAXY_LOCAL_ENV_FILE"
fi

GALAXY_PID=${GALAXY_PID:-galaxy.pid}
GALAXY_LOG=${GALAXY_LOG:-galaxy.log}
PID_FILE=$GALAXY_PID
LOG_FILE=$GALAXY_LOG

parse_common_args $@

run_common_start_up

setup_python

if [ ! -z "$GALAXY_RUN_WITH_TEST_TOOLS" ];
then
    export GALAXY_CONFIG_OVERRIDE_TOOL_CONFIG_FILE="test/functional/tools/samples_tool_conf.xml"
    export GALAXY_CONFIG_ENABLE_BETA_WORKFLOW_MODULES="true"
    export GALAXY_CONFIG_OVERRIDE_ENABLE_BETA_TOOL_FORMATS="true"
    export GALAXY_CONFIG_OVERRIDE_WEBHOOKS_DIR="test/functional/webhooks"
fi

if [ -n "$GALAXY_UNIVERSE_CONFIG_DIR" ]; then
    python ./scripts/build_universe_config.py "$GALAXY_UNIVERSE_CONFIG_DIR"
fi

set_galaxy_config_file_var

if [ "$INITIALIZE_TOOL_DEPENDENCIES" -eq 1 ]; then
    # Install Conda environment if needed.
    python ./scripts/manage_tool_dependencies.py init_if_needed
fi
