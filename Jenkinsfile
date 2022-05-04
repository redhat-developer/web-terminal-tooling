#!/usr/bin/env groovy
import groovy.transform.Field

// PARAMETERS for this pipeline:
def String SOURCE_BRANCH = "main"
def String DWNSTM_BRANCH = "web-terminal-1.5-rhel-8"

def String SOURCE_REPO = "redhat-developer/web-terminal-tooling" // source repo from which to find commits

def SOURCE_SHA=""

def DS_MIDSTM_BRANCH="devspaces-3-rhel-8"
def REPO_NAME="web-terminal-tooling"

// container.yaml lists only x86_64 so we can't build on any other arches (s390x-rhel8||ppc64le-rhel8)
def String nodeLabel = 'x86_64-rhel8' 

timeout(300) {
  node(nodeLabel) {
    stage ("Sync repos on ${nodeLabel}") {
      wrap([$class: 'TimestamperBuildWrapper']) {
        sh('curl -sSLO https://raw.githubusercontent.com/redhat-developer/devspaces/' + DS_MIDSTM_BRANCH + '/product/util2.groovy')
        def util = load "${WORKSPACE}/util2.groovy"
        cleanWs()
        withCredentials([string(credentialsId:'crw_devstudio-release-token', variable: 'GITHUB_TOKEN')]) {
            println "########################################################################################################"
            println "##  Clone and update github.com/${SOURCE_REPO}.git"
            println "########################################################################################################"
            util.cloneRepo("https://github.com/${SOURCE_REPO}.git", "${WORKSPACE}/sources", SOURCE_BRANCH, false)

            util.updateBaseImages("${WORKSPACE}/sources/", SOURCE_BRANCH, "", DS_MIDSTM_BRANCH)
            SOURCE_SHA = util.getLastCommitSHA("${WORKSPACE}/sources")
            println "Got SOURCE_SHA in sources folder: " + SOURCE_SHA

            println "########################################################################################################"
            println "##  Sync web-terminal-tooling to pkgs.devel"
            println "########################################################################################################"
            util.cloneRepo("ssh://crw-build@pkgs.devel.redhat.com/containers/${REPO_NAME}", "${WORKSPACE}/targetdwn", DWNSTM_BRANCH, false)

            // copy everything from sources directory to target directory and delete anything extra
            sh('''
SOURCEDIR="${WORKSPACE}/sources"
TARGETDIR="${WORKSPACE}/targetdwn"
echo ".github/
.git/
.gitattributes
sources
" > /tmp/rsync-excludes
echo "Rsync ${SOURCEDIR} to ${TARGETDIR}"
rsync -azrlt --checksum --exclude-from /tmp/rsync-excludes --delete ${SOURCEDIR}/ ${TARGETDIR}/
rm -f /tmp/rsync-excludes

# regenerate the dockerfile then push to dist-git
cd ${WORKSPACE}/targetdwn

./build/generate_dockerfile.sh -o Dockerfile -m brew
./get-sources.sh -u

cat .gitignore
rm -rf container-root-*.tgz

git update-index --refresh || true # ignore timestamp updates
if [[ \$(git diff-index HEAD --) ]]; then # file changed
    export KRB5CCNAME=/var/tmp/crw-build_ccache
    git add . -A -f
    git commit -s -m "[mid2dwn] Sync from ''' + SOURCE_REPO + ''' @ ''' + SOURCE_SHA + '''"
    git push origin ''' + DWNSTM_BRANCH + ''' || true
fi
            ''')
          } // withCredentials
      } // wrap
    } // stage
  } // node
} // timeout