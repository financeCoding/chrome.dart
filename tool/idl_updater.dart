library idl_updater;

import 'package:unscripted/unscripted.dart';

main(arguments) => declare(IdlUpdater).execute(arguments);
// rm -rf idl
// svn co --non-interactive --trust-server-cert https://src.chromium.org/chrome/trunk/src/chrome/common/extensions/api idl
// ls idl
// ls -a idl
// cd idl
// svn info|grep Revision

// TODO: checkout from svn
// TODO: delete unused files, .svn, OWNERS, PRESUBMIT.py, PRESUBMIT_test.py, .cc, .h

class IdlUpdater {
  final String configFile;

  @Command(help: "help")
  IdlUpdater({this.configFile: 'meta/idl_revision.json'});

  @SubCommand(help: "blah")
  latest() {

  }

  @SubCommand(help: "blah")
  revision(String rev) {

  }

  @SubCommand(help: "blah")
  printCurrent() {

  }
}

