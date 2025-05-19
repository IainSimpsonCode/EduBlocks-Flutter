# EduBlocks Flutter
EduBlocks Flutter is a high-fidelity protoype of the EduBlocks tool from Anaconda.
This tool is designed to allow researchers to test new features for the EduBlocks app in a controlled environment. As part of the controlled environment, users are restricted to only doing a set project, and all backend features (such as the compiler) is removed. In it's place, researchers can set what each code block should output to the code panel, and can dictate what order blocks should be placed in. This restriction limits the user to only focusing on the new features and interactions, and not focusing on the code or on features irrelevant to the current study.

## Info for Developers
Branches:
- main
- development

### main
Only **stable and useable** versions should be shipped to main. When code is run from main, there should not be visible errors, or aspects preventing the code from running.

### development
This branch should be used when developing new features on top of the version from *main*. This branch can contain any number of errors, that is what the branch is there for! Once a new feature is added, and the version is stable, it should be merged with *main* to release the new feature and create a reliable version history.
