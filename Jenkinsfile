properties([gitLabConnection('Gitlab')])
node {
  checkout scm
  gitlabCommitStatus {
    vixnsCi('.vixns-ci.yml');
  }
}
