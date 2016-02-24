# Change Log

## [v1.2.1](https://github.com/chef/knife-cloud/tree/v1.2.1) (2016-02-24)

[Full Changelog](https://github.com/chef/knife-cloud/compare/v1.2.0...v1.2.1)

**Merged pull requests:**

- Passing bootstrap\_ip\_address as an array object instead of string [\#101](https://github.com/chef/knife-cloud/pull/101) ([NimishaS](https://github.com/NimishaS))
- Added new knife windows options [\#98](https://github.com/chef/knife-cloud/pull/98) ([siddheshwar-more](https://github.com/siddheshwar-more))

## [v1.2.0](https://github.com/chef/knife-cloud/tree/v1.2.0) (2015-07-18)
[Full Changelog](https://github.com/chef/knife-cloud/compare/v1.2.0.rc.0...v1.2.0)

**Closed issues:**

- both -F json ad --format json does not work  [\#91](https://github.com/chef/knife-cloud/issues/91)

**Merged pull requests:**

- Adding support for floating ip commands [\#96](https://github.com/chef/knife-cloud/pull/96) ([Vasu1105](https://github.com/Vasu1105))

## [v1.2.0.rc.0](https://github.com/chef/knife-cloud/tree/v1.2.0.rc.0) (2015-06-25)
[Full Changelog](https://github.com/chef/knife-cloud/compare/v1.1.0...v1.2.0.rc.0)

**Merged pull requests:**

- Show result in the format provided by user in -F or --format option [\#93](https://github.com/chef/knife-cloud/pull/93) ([NimishaS](https://github.com/NimishaS))

## [v1.1.0](https://github.com/chef/knife-cloud/tree/v1.1.0) (2015-06-18)
[Full Changelog](https://github.com/chef/knife-cloud/compare/v1.1.0.rc.0...v1.1.0)

**Merged pull requests:**

- bumped the version for a full release [\#92](https://github.com/chef/knife-cloud/pull/92) ([jjasghar](https://github.com/jjasghar))

## [v1.1.0.rc.0](https://github.com/chef/knife-cloud/tree/v1.1.0.rc.0) (2015-06-10)
[Full Changelog](https://github.com/chef/knife-cloud/compare/1.0.1...v1.1.0.rc.0)

**Closed issues:**

- Unable to create server w/ v1.0 [\#82](https://github.com/chef/knife-cloud/issues/82)

**Merged pull requests:**

- Updated an RC version [\#90](https://github.com/chef/knife-cloud/pull/90) ([jjasghar](https://github.com/jjasghar))
- Updated the readme [\#89](https://github.com/chef/knife-cloud/pull/89) ([jjasghar](https://github.com/jjasghar))
- the chef\_version is broken [\#88](https://github.com/chef/knife-cloud/pull/88) ([jjasghar](https://github.com/jjasghar))
- Looks like you doubled up some code [\#87](https://github.com/chef/knife-cloud/pull/87) ([jjasghar](https://github.com/jjasghar))
- Update knife-cloud to have all the new bootstrap options of Chef 12 [\#85](https://github.com/chef/knife-cloud/pull/85) ([NimishaS](https://github.com/NimishaS))
- remove 'em-winrm' gem dependency [\#83](https://github.com/chef/knife-cloud/pull/83) ([prabhu-das](https://github.com/prabhu-das))

## [1.0.1](https://github.com/chef/knife-cloud/tree/1.0.1) (2014-09-19)
[Full Changelog](https://github.com/chef/knife-cloud/compare/1.0.0...1.0.1)

**Closed issues:**

- floating-ips seem to throw an error with knife-openstack [\#78](https://github.com/chef/knife-cloud/issues/78)
- -i and -x no longer work with ssh [\#74](https://github.com/chef/knife-cloud/issues/74)

**Merged pull requests:**

- Limit hostnames to 15 characters \(for windows\) [\#81](https://github.com/chef/knife-cloud/pull/81) ([hh](https://github.com/hh))

## [1.0.0](https://github.com/chef/knife-cloud/tree/1.0.0) (2014-08-11)
[Full Changelog](https://github.com/chef/knife-cloud/compare/1.0.0.rc.0...1.0.0)

**Merged pull requests:**

- Release knife-cloud 1.0.0 [\#80](https://github.com/chef/knife-cloud/pull/80) ([adamedx](https://github.com/adamedx))
- \[knife-cloud\] Change Fog to dev dependency [\#79](https://github.com/chef/knife-cloud/pull/79) ([siddheshwar-more](https://github.com/siddheshwar-more))

## [1.0.0.rc.0](https://github.com/chef/knife-cloud/tree/1.0.0.rc.0) (2014-07-27)
**Closed issues:**

- -a for floating IPs is broken with knife-openstack [\#76](https://github.com/chef/knife-cloud/issues/76)

**Merged pull requests:**

- Release candidate knife-cloud 1.0.0.rc.0 [\#77](https://github.com/chef/knife-cloud/pull/77) ([adamedx](https://github.com/adamedx))
- \[knife-cloud\] Common short options in ssh & winrm \(SSH override winrm config\) [\#75](https://github.com/chef/knife-cloud/pull/75) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] Add missing bootstrap options to knife-cloud [\#73](https://github.com/chef/knife-cloud/pull/73) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Added changes for template-file option [\#72](https://github.com/chef/knife-cloud/pull/72) ([kaustubh-d](https://github.com/kaustubh-d))
- knife-ec2 master to knife-ec2 knife-cloud sync [\#71](https://github.com/chef/knife-cloud/pull/71) ([prabhu-das](https://github.com/prabhu-das))
- Specify name or id for image and flavor in server create [\#70](https://github.com/chef/knife-cloud/pull/70) ([kaustubh-d](https://github.com/kaustubh-d))
- \[knife-cloud\] Fixes for rspec deprecated warnings [\#69](https://github.com/chef/knife-cloud/pull/69) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Sorting list outputs by sort\_by\_field with case insensitive sort. [\#68](https://github.com/chef/knife-cloud/pull/68) ([prabhu-das](https://github.com/prabhu-das))
- \[knife-cloud\] KNIFE-477: Delete server by name if instance\_id isn't found [\#67](https://github.com/chef/knife-cloud/pull/67) ([ameyavarade](https://github.com/ameyavarade))
- Changes for enabling network list [\#66](https://github.com/chef/knife-cloud/pull/66) ([prabhu-das](https://github.com/prabhu-das))
- Refactored redundant code. [\#65](https://github.com/chef/knife-cloud/pull/65) ([ameyavarade](https://github.com/ameyavarade))
- Fixed code and spec for Excon error [\#64](https://github.com/chef/knife-cloud/pull/64) ([prabhu-das](https://github.com/prabhu-das))
- Remove extraneous use of active-support for the better good [\#63](https://github.com/chef/knife-cloud/pull/63) ([btm](https://github.com/btm))
- Rebase integration tests [\#61](https://github.com/chef/knife-cloud/pull/61) ([muktaa](https://github.com/muktaa))
- OC-10611 implementation for custom\_arguments passed to Fog [\#57](https://github.com/chef/knife-cloud/pull/57) ([prabhu-das](https://github.com/prabhu-das))
- Updated test windows template to latest knife windows \( -V 0.5.14\) template. [\#56](https://github.com/chef/knife-cloud/pull/56) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-11210 EC2 refactored code has ambiguity in the name of short-option for Gateway & Groups [\#54](https://github.com/chef/knife-cloud/pull/54) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-11204 - Exception handling and abstraction [\#53](https://github.com/chef/knife-cloud/pull/53) ([kaustubh-d](https://github.com/kaustubh-d))
- OC-11140 nested values support [\#51](https://github.com/chef/knife-cloud/pull/51) ([prabhu-das](https://github.com/prabhu-das))
- OC-10823 knife-ec2 server create and bootstrap windows instance using ssh [\#48](https://github.com/chef/knife-cloud/pull/48) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Handle fog errors in knife-cloud [\#47](https://github.com/chef/knife-cloud/pull/47) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Updated code to reflect server name for both openstack and ec2 when --ch... [\#46](https://github.com/chef/knife-cloud/pull/46) ([prabhu-das](https://github.com/prabhu-das))
- OC-10520 knife-cloud should add data summary methods [\#43](https://github.com/chef/knife-cloud/pull/43) ([ameyavarade](https://github.com/ameyavarade))
- OC-9950 Support common options of knife bootstrap in knife cloud [\#42](https://github.com/chef/knife-cloud/pull/42) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-9596: Succesfully run the integration tests on jenkins for knife-openstack\(based on knife-cloud\) [\#41](https://github.com/chef/knife-cloud/pull/41) ([adamedx](https://github.com/adamedx))
- OC-9430: Knife cloud should support endpoint config and cli option [\#40](https://github.com/chef/knife-cloud/pull/40) ([adamedx](https://github.com/adamedx))
- Let knife-windows find the template based on distro supplied. [\#38](https://github.com/chef/knife-cloud/pull/38) ([chirag-jog](https://github.com/chirag-jog))
- Updated rspec tests for server list, create command [\#36](https://github.com/chef/knife-cloud/pull/36) ([adamedx](https://github.com/adamedx))
- Updated rspec tests for server list, create command [\#35](https://github.com/chef/knife-cloud/pull/35) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-9613: os\_image\_type should be inferred from bootstrap protocol if not specified to knife cloud [\#34](https://github.com/chef/knife-cloud/pull/34) ([adamedx](https://github.com/adamedx))
- OC-9533 knife CLOUD server list needs to expose Chef data \(node names, attributes\) [\#33](https://github.com/chef/knife-cloud/pull/33) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-9207: OC-9390: Dynamic Fog gem versioning, Exit code handling [\#31](https://github.com/chef/knife-cloud/pull/31) ([adamedx](https://github.com/adamedx))
- OC 9450 - Auto generate chef node name when not input by user [\#30](https://github.com/chef/knife-cloud/pull/30) ([muktaa](https://github.com/muktaa))
- OC-8965: Provide CLI option to delete server on bootstrap failure [\#28](https://github.com/chef/knife-cloud/pull/28) ([adamedx](https://github.com/adamedx))
- OC-9368 Image\_os\_type option should be compulsory in knife-openstack. [\#26](https://github.com/chef/knife-cloud/pull/26) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Sprint 86: Merge Gem dependencies, Travis support [\#24](https://github.com/chef/knife-cloud/pull/24) ([adamedx](https://github.com/adamedx))
- oc 8965 delete server when bootstrap fails [\#23](https://github.com/chef/knife-cloud/pull/23) ([muktaa](https://github.com/muktaa))
- 9107 knife cloud travis [\#22](https://github.com/chef/knife-cloud/pull/22) ([muktaa](https://github.com/muktaa))
- Windows bootstrap support + correct gem dependency for knife-windows [\#20](https://github.com/chef/knife-cloud/pull/20) ([muktaa](https://github.com/muktaa))
- Windows bootstrap support + correct gem dependency for knife-windows [\#18](https://github.com/chef/knife-cloud/pull/18) ([muktaa](https://github.com/muktaa))
- OC-8572: Knife cloud openstack create with bootstrap Windows [\#16](https://github.com/chef/knife-cloud/pull/16) ([adamedx](https://github.com/adamedx))
- OC-8822: Knife cloud openstack server list command [\#15](https://github.com/chef/knife-cloud/pull/15) ([adamedx](https://github.com/adamedx))
- Resource Listing changes \(OC 8822, 8824, 8825, 8826\) [\#13](https://github.com/chef/knife-cloud/pull/13) ([muktaa](https://github.com/muktaa))
- Add notices to sources [\#12](https://github.com/chef/knife-cloud/pull/12) ([adamedx](https://github.com/adamedx))
- First working version of knife-cloud \(merged and rebased\) [\#10](https://github.com/chef/knife-cloud/pull/10) ([chirag-jog](https://github.com/chirag-jog))
- Knife cloud plugin [\#9](https://github.com/chef/knife-cloud/pull/9) ([muktaa](https://github.com/muktaa))
- OC-8310: Base framework library for knife plug-in tests [\#8](https://github.com/chef/knife-cloud/pull/8) ([adamedx](https://github.com/adamedx))
- OC-8427: OC-8426: OC-8425: OC-8428: Unit tests for knife-cloud [\#7](https://github.com/chef/knife-cloud/pull/7) ([adamedx](https://github.com/adamedx))
- OC-8312: Knife-cloud gem skeleton [\#6](https://github.com/chef/knife-cloud/pull/6) ([adamedx](https://github.com/adamedx))
- OC-8312 Knife-cloud gem skeleton [\#3](https://github.com/chef/knife-cloud/pull/3) ([kaustubh-d](https://github.com/kaustubh-d))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
