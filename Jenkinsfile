#!/usr/bin/env groovy

// PARAMETERS for this pipeline:
// SOURCE_BRANCH = "v1.0.x" // branch of source repo from which to find and sync commits to pkgs.devel repo
// DWNSTM_BRANCH = 'web-terminal-1.0-rhel-8' // target branch in dist-git repo, eg., web-terminal-1.0-rhel-8

def SOURCE_REPO = "redhat-developer/web-terminal-tooling" //source repo from which to find and sync commits to pkgs.devel repo
def DWNSTM_REPO = "containers/web-terminal-tooling" // dist-git repo to use as target for everything

def buildNode = "rhel7-releng" // slave label
timeout(120) {
  node("${buildNode}"){
    stage "Sync repos"
    wrap([$class: 'TimestamperBuildWrapper']) {
      cleanWs()
      withCredentials([string(credentialsId:'devstudio-release.token', variable: 'GITHUB_TOKEN'), 
      file(credentialsId: 'crw-build.keytab', variable: 'CRW_KEYTAB')]) {
        checkout([$class: 'GitSCM',
          branches: [[name: "${SOURCE_BRANCH}"]],
          doGenerateSubmoduleConfigurations: false,
          credentialsId: 'devstudio-release',
          poll: true,
          extensions: [
            [$class: 'RelativeTargetDirectory', relativeTargetDir: "sources"],
          ],
          submoduleCfg: [],
          userRemoteConfigs: [[url: "https://github.com/${SOURCE_REPO}.git"]]])

          def BOOTSTRAP = '''
          export GITHUB_TOKEN=''' + GITHUB_TOKEN + '''
          export SOURCE_REPO=''' + SOURCE_REPO + '''
          export SOURCE_BRANCH=''' + SOURCE_BRANCH + '''
          export DWNSTM_REPO=''' + DWNSTM_REPO + '''
          export DWNSTM_BRANCH=''' + DWNSTM_BRANCH + '''
          export CRW_KEYTAB=''' + CRW_KEYTAB + '''
          export USER=''' + USER + '''
          curl -L -s -S https://raw.githubusercontent.com/redhat-developer/web-terminal-operator/v1.0.x/bootstrap-sync.sh -o ./sync.sh
          chmod +x ./sync.sh
          ./sync.sh
          '''

          sh BOOTSTRAP + '''
          # initialize kerberos
          export KRB5CCNAME=/var/tmp/crw-build_ccache
          kinit "crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@REDHAT.COM" -kt ''' + CRW_KEYTAB + '''
          klist # verify working

          cd ${WORKSPACE}/sources
          SOURCE_SHA=$(git rev-parse HEAD)
          cd ..

          cd ${WORKSPACE}/targetdwn

          # Regenerate the Dockerfile
          ./build/generate_dockerfile.sh -o Dockerfile -m brew

          # Regenerate the sources
          # in https://mojo.redhat.com/docs/DOC-1045187 it says: rhpkg new-sources checks if the file already exists in the cache, so it will not upload the same file twice (this is checked by module name, source file name and checksum).
          # Since all 3 are the same each time we should just be able to update each time and it will only be replaced when the checksum changes
          ./get-sources-jenkins.sh -u

          # Update the base image. We update the base image after regenerating the template so that
          # the underlying docker image will always be the most updated
          curl -L -s -S https://raw.githubusercontent.com/redhat-developer/codeready-workspaces/master/product/updateBaseImages.sh -o /tmp/updateBaseImages.sh
          chmod +x /tmp/updateBaseImages.sh
          /tmp/updateBaseImages.sh -b ''' + DWNSTM_BRANCH + '''

          if [[ $(git diff --name-only) ]]; then # file changed
            git add . -A
            git commit -s -m "[sync] Updated from ${SOURCE_REPO} @ ${SOURCE_SHA:0:8} " || true
            git push origin ${DWNSTM_BRANCH} || true
            echo "[sync] Updated from ${SOURCE_REPO} @ ${SOURCE_SHA:0:8} "
          else
            echo "Source and downstream contents are the same. No need to sync"
          fi
          '''
      }
    }
  }
}
