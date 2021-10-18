---
name: Release
about: Prioritize a release milestone's issues
title: 'v#.#.#'
labels: release
assignees: ''

---
<!--
- Tasks should be marked off when a linked PR for them is ready for review
- Order each section from highest to lowest priority
- Each issue should be listed as a subtask under the pull request for it.
-->

Issues
-----------------
- [ ] #PR
  - [ ] #issue1
  - [ ] #issue1

Release
-----------------
Once all the PRs, begin the release process:
- [ ] Release PR
  - [ ] Update release number
  - [ ] Check that the Conda recipe build number is correct.  
        It should be reset to 0 for the first build of a version number and 
        then incremented for subsequent rebuilds.
  - [ ] Make sure it is labeled as a "release"
- [ ] Check the Draft GitHub Release
  - [ ] Make sure the conda package is included in the draft
  - [ ] Make sure the documentation is included in the draft
  - [ ] Check the Release notes, and update as needed. 
        (generate them using the auto-gen button)
- [ ] Publish GitHub Release
  - Releases the Conda package to IDS
  - Updates IDS Production Environments
  - Releases documentation
