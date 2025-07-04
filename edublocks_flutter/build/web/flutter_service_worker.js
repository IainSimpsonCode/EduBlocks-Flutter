'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"app_assets/blocks.json": "4ff67239ee5587af24df27708109e6fa",
"app_assets/block_images/import/math.png": "e3bfca6968d46de169cc1b2756f96c69",
"app_assets/block_images/import/random.png": "3665e4b5af5ba192b5a6fc28620829ce",
"app_assets/block_images/import/time.png": "03f87e93015ce9f70badcedb18da6e08",
"app_assets/block_images/lists/friends-append.png": "9adab02944756f424e9a99a07654f4b7",
"app_assets/block_images/lists/fruits-list-append-grapes.png": "b90bb07d8278002538077319b579c558",
"app_assets/block_images/lists/fruits-list-remove_item3.png": "15110fbbb3cecdcc610194aa299eda21",
"app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11Small.png": "3076157434f46af9b840c13f692ff626",
"app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11_1Block.png": "cdfac7ae64a082ca4fd08f6d57f86d7c",
"app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11_2Blocks.png": "76e056d0eac0e07b39d0f6459bc916b2",
"app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11_3Blocks.png": "7e91aa3cb7d96f6fa11da1a5c83a87e8",
"app_assets/block_images/logic/countLessThan10/ifCountLessThan10_1Block.png": "453c121e39859f92f1058b34a477b856",
"app_assets/block_images/logic/countLessThan10/ifCountLessThan10_2Blocks.png": "51f9a656e2239df63d601a1f79a49912",
"app_assets/block_images/logic/countLessThan10/ifCountLessThan10_3Blocks.png": "137a6a801f59d8bc5859c8d1bdd4edc8",
"app_assets/block_images/logic/countLessThan10/ifCountLessThan10_Small.png": "e75f9cc7ba9f9496241954edcd8c6b51",
"app_assets/block_images/logic/else/elseSmall.png": "7243e338bcd626a8d8c2ea77bffd4a05",
"app_assets/block_images/logic/else/elseSmall_1Block.png": "8bd5a22bbeed5eb96552e319bf55f059",
"app_assets/block_images/logic/else/else_1Block.png": "b5d7b119c54efaeaf9c80e895a3c4d37",
"app_assets/block_images/logic/else/else_2Blocks.png": "4e797306ebfe1336c03ff1fd2b81d4d0",
"app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16Small.png": "da42e2d9409bb4df5e3b9fb79e06c7b2",
"app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_1Block.png": "e4de650268abb3fee1e8aae8fd6b5c50",
"app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_2Blocks.png": "31190ac171da19937c1c0b9321a82c9a",
"app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_3Blocks.png": "58240b15ac552896211163488c3f8757",
"app_assets/block_images/loops/for_i_inRange/for-loop.png": "741463e039d0500453e52c70f7d0d229",
"app_assets/block_images/loops/for_i_inRange/for-loopSmall.png": "2ba50ee31c21a400c42df2cba1bdd9ea",
"app_assets/block_images/loops/for_i_inRange/for-loop_1Block.png": "209c3a6f597dfebd4cadedb91fbb6e6a",
"app_assets/block_images/loops/for_i_inRange/for-loop_2Blocks.png": "017a22ec556069a14524001cc5b212b0",
"app_assets/block_images/loops/for_i_inRange/for-loop_3Blocks.png": "d969d6150c1772d6cba97c89857b0a52",
"app_assets/block_images/loops/whileGrades/whileGradeSmall.png": "83b708413988119521253b39bf9f92ec",
"app_assets/block_images/loops/whileGrades/whileGrade_1Block.png": "e40c3d03e14293819807f96e13c1360a",
"app_assets/block_images/loops/whileGrades/whileGrade_2Blocks.png": "ca72ca9a343445ec5fb0b91054f62169",
"app_assets/block_images/loops/whileGrades/whileGrade_3Blocks.png": "7474b5ca9d3c437c50c3fefd988de19f",
"app_assets/block_images/loops/whileGrades/whilte-loop.png": "3c3816670504b140f1c85275b8dd5337",
"app_assets/block_images/loops/whileTrue/whileTrue.png": "9d9d30ea73700719bcfa449f9eb54f2d",
"app_assets/block_images/loops/whileTrue/whileTrue.psd": "746a837c8aef0efa1828c42ddd0f2c9b",
"app_assets/block_images/loops/whileTrue/whileTrue2Blocks.png": "46416cb69cce13c533344ef40c148f23",
"app_assets/block_images/loops/whileTrue/whileTrue3Blocks.png": "5840367e5377313ea024eeebe8db77e2",
"app_assets/block_images/loops/whileTrue/whileTrue4Blocks.png": "10e406d3e1fb0af3761c02fca9228618",
"app_assets/block_images/loops/whileTrue/whileTrueSmallV1.png": "7c7c137512ad3face7f3373ffcc1c1d7",
"app_assets/block_images/loops/whileTrue/whileTrueSmallV2.png": "8ccb28c7c681511a387ce9e02c88b58d",
"app_assets/block_images/startHere.png": "165a83b0b03d47db6edc23ce98ff60fb",
"app_assets/block_images/statements/print.png": "0e932094a7049c155815863f97fa0f4e",
"app_assets/block_images/statements/print_favourite-fruit.png": "c430ca2dfebbdaf12c7f103807819e7a",
"app_assets/block_images/statements/print_friends_0.png": "2b380130762a48b6ff3e514830e94455",
"app_assets/block_images/statements/print_fruit-2.png": "86889ce7d28b36caf0365d21ebd40d2a",
"app_assets/block_images/statements/print_fruit-3.png": "2e0be85ade4145161e619623353727c9",
"app_assets/block_images/statements/print_fruits.png": "3ef43e1adcff33f31530f3aea441ae02",
"app_assets/block_images/statements/print_high-school.png": "17c009405c1c698827e0d060b8cbfbf5",
"app_assets/block_images/statements/print_my-friend-string.png": "827aedf1bd421ed43c707f3ca8e6ba28",
"app_assets/block_images/statements/print_my-grades.png": "b9ebcdf4807338b9645789091e4cd395",
"app_assets/block_images/statements/print_number1+number2.png": "c7f5878ed6dbb1300aab176878f76352",
"app_assets/block_images/statements/print_primary-school.png": "cda76f014a47913c1358a7b2849d9d1b",
"app_assets/block_images/statements/print_random-choice.png": "cde1721effb1e290f085ba0771578daa",
"app_assets/block_images/statements/print_random-fruits.png": "16f63ed800dd3a7da0844e51da1fc639",
"app_assets/block_images/statements/print_string.png": "67b406b074e5fc8ab5e71fbb1e704f91",
"app_assets/block_images/statements/print_total-grades.png": "6d590471f08e9bb53cab9fba70a93635",
"app_assets/block_images/statements/print_you-are-old.png": "d86a01875b60a17d296b0489165cf434",
"app_assets/block_images/variables/age-variable_input.png": "3b2ed72a8638e6110c4cabb75c793569",
"app_assets/block_images/variables/age10.png": "751931c4cd53e4eb56169248c2ed4cb3",
"app_assets/block_images/variables/age14.png": "c4c9cc1fc95ba11e2420b0323e97a5bf",
"app_assets/block_images/variables/age22.png": "e5b53e9c276c3bf065efb3543caf3fbd",
"app_assets/block_images/variables/count+=1.png": "779d02ca601470f619e6c7a9fb2a89d8",
"app_assets/block_images/variables/count=0.png": "f7ead23a53cbceef05e9a5f2e1fbe83c",
"app_assets/block_images/variables/friends-list.png": "03dcfe6228e5bbb1400dd55674679d0d",
"app_assets/block_images/variables/friends-variable.png": "8f40b637e92364fd3d21d6d4cf87bbdd",
"app_assets/block_images/variables/fruits-list.png": "1c1074488ec34eed47b38f559a5d508e",
"app_assets/block_images/variables/grade1.png": "76698b7efe4e7ae17978c067be4deb08",
"app_assets/block_images/variables/grade2.png": "335193fd9bb94092f9149cae1801d565",
"app_assets/block_images/variables/grade3.png": "7a31a5d4479d658d93676f5b1f91cff2",
"app_assets/block_images/variables/grade4.png": "40c80208e098641df0609ea808bfe22d",
"app_assets/block_images/variables/i_variable-plus-1.png": "f3424549ea9d4a9ab5a8a686b8a6f269",
"app_assets/block_images/variables/i_variable.png": "dbfa8724e191ed693dd26164b0394cbe",
"app_assets/block_images/variables/my-grades_list.png": "18bcb64e29f693d47d7cfdc3f902f894",
"app_assets/block_images/variables/number1_variable.png": "92c7ba3d84c8572a2d5d716281741146",
"app_assets/block_images/variables/number2_variable.png": "6e260edb960ecf74168754ca939d9af2",
"app_assets/block_images/variables/total-grades.png": "4e42dc44488148968c8b372a16701970",
"app_assets/block_images/variables/total-grades_to-int.png": "9439f9887809f5941fb5a04bbdde8a94",
"app_assets/categories.json": "5abdc29bc376cb4f331b5d5a0eecd24b",
"app_assets/category_icons/arrows.svg": "153a2be7494629aabb838a80a1a2f0c4",
"app_assets/category_icons/bars.svg": "04fb518fdcff49fc34022f3dab074b43",
"app_assets/category_icons/exclamation.svg": "0c48d3c650d36c91480878eab2190c02",
"app_assets/category_icons/flag.svg": "a0865837b8a07139d1c896cd1e8a7700",
"app_assets/category_icons/list.svg": "d3927b86e7aff58aa0d012c4c9a81d35",
"app_assets/category_icons/play.svg": "8e03205ba6239cf12dd2f4b853a60dd0",
"app_assets/category_icons/rotateright.svg": "5c98debb875c6c9486314e186316fe74",
"app_assets/category_icons/shuffle.svg": "87c2dcf84a1cf628d90e03b62c86156a",
"app_assets/category_icons/squareroot.svg": "2c02e77ceaf4a99dc2b916a624ff459d",
"app_assets/category_icons/textsize.svg": "74357cb361ca3e5c3d50b6615ee31dc2",
"app_assets/category_icons/trash.svg": "b973ff8fcc8f3597e8c8d06b9e6026a6",
"app_assets/category_icons/upload.svg": "5c072b4978ee571f29e16902482995e5",
"app_assets/solutions.json": "f8ab0e4b3d4136a71fc4d1548ed37614",
"app_assets/sounds/click.mp3": "f71910b391538a67231e088bba0d47eb",
"app_assets/sounds/click.wav": "50ac7ca2a6522be84486a5a14afddd83",
"app_assets/sounds/disconnect.wav": "409e7fabb73e895a642b9d3899d6ee7f",
"assets/app_assets/blocks.json": "4035b39a971fd33388e43703ec9f8ea3",
"assets/app_assets/block_images/import/math.png": "e3bfca6968d46de169cc1b2756f96c69",
"assets/app_assets/block_images/import/random.png": "3665e4b5af5ba192b5a6fc28620829ce",
"assets/app_assets/block_images/import/time.png": "03f87e93015ce9f70badcedb18da6e08",
"assets/app_assets/block_images/lists/friends-append.png": "9adab02944756f424e9a99a07654f4b7",
"assets/app_assets/block_images/lists/fruits-list-append-grapes.png": "b90bb07d8278002538077319b579c558",
"assets/app_assets/block_images/lists/fruits-list-remove_item3.png": "15110fbbb3cecdcc610194aa299eda21",
"assets/app_assets/block_images/lists/list-extend-ks1.png": "fad25bd63c7d5130ece9b4eddcdd8712",
"assets/app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11Small.png": "3076157434f46af9b840c13f692ff626",
"assets/app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11_1Block.png": "cdfac7ae64a082ca4fd08f6d57f86d7c",
"assets/app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11_2Blocks.png": "76e056d0eac0e07b39d0f6459bc916b2",
"assets/app_assets/block_images/logic/ageLessThan11/ifAgeLessThan11_3Blocks.png": "7e91aa3cb7d96f6fa11da1a5c83a87e8",
"assets/app_assets/block_images/logic/countLessThan10/ifCountLessThan10_1Block.png": "453c121e39859f92f1058b34a477b856",
"assets/app_assets/block_images/logic/countLessThan10/ifCountLessThan10_2Blocks.png": "51f9a656e2239df63d601a1f79a49912",
"assets/app_assets/block_images/logic/countLessThan10/ifCountLessThan10_3Blocks.png": "137a6a801f59d8bc5859c8d1bdd4edc8",
"assets/app_assets/block_images/logic/countLessThan10/ifCountLessThan10_Small.png": "e75f9cc7ba9f9496241954edcd8c6b51",
"assets/app_assets/block_images/logic/else/elseSmall.png": "7243e338bcd626a8d8c2ea77bffd4a05",
"assets/app_assets/block_images/logic/else/elseSmall_1Block.png": "8bd5a22bbeed5eb96552e319bf55f059",
"assets/app_assets/block_images/logic/else/else_1Block.png": "b5d7b119c54efaeaf9c80e895a3c4d37",
"assets/app_assets/block_images/logic/else/else_2Blocks.png": "4e797306ebfe1336c03ff1fd2b81d4d0",
"assets/app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16Small.png": "da42e2d9409bb4df5e3b9fb79e06c7b2",
"assets/app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_1Block.png": "e4de650268abb3fee1e8aae8fd6b5c50",
"assets/app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_2Blocks.png": "31190ac171da19937c1c0b9321a82c9a",
"assets/app_assets/block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_3Blocks.png": "58240b15ac552896211163488c3f8757",
"assets/app_assets/block_images/loops/for_i_inRange/for-loop.png": "741463e039d0500453e52c70f7d0d229",
"assets/app_assets/block_images/loops/for_i_inRange/for-loopSmall.png": "2ba50ee31c21a400c42df2cba1bdd9ea",
"assets/app_assets/block_images/loops/for_i_inRange/for-loop_1Block.png": "209c3a6f597dfebd4cadedb91fbb6e6a",
"assets/app_assets/block_images/loops/for_i_inRange/for-loop_2Blocks.png": "017a22ec556069a14524001cc5b212b0",
"assets/app_assets/block_images/loops/for_i_inRange/for-loop_3Blocks.png": "d969d6150c1772d6cba97c89857b0a52",
"assets/app_assets/block_images/loops/whileGrades/whileGradeSmall.png": "83b708413988119521253b39bf9f92ec",
"assets/app_assets/block_images/loops/whileGrades/whileGrade_1Block.png": "e40c3d03e14293819807f96e13c1360a",
"assets/app_assets/block_images/loops/whileGrades/whileGrade_2Blocks.png": "ca72ca9a343445ec5fb0b91054f62169",
"assets/app_assets/block_images/loops/whileGrades/whileGrade_3Blocks.png": "7474b5ca9d3c437c50c3fefd988de19f",
"assets/app_assets/block_images/loops/whileGrades/whilte-loop.png": "3c3816670504b140f1c85275b8dd5337",
"assets/app_assets/block_images/loops/whileTrue/whileTrue.png": "9d9d30ea73700719bcfa449f9eb54f2d",
"assets/app_assets/block_images/loops/whileTrue/whileTrue.psd": "746a837c8aef0efa1828c42ddd0f2c9b",
"assets/app_assets/block_images/loops/whileTrue/whileTrue2Blocks.png": "46416cb69cce13c533344ef40c148f23",
"assets/app_assets/block_images/loops/whileTrue/whileTrue3Blocks.png": "5840367e5377313ea024eeebe8db77e2",
"assets/app_assets/block_images/loops/whileTrue/whileTrue4Blocks.png": "10e406d3e1fb0af3761c02fca9228618",
"assets/app_assets/block_images/loops/whileTrue/whileTrueSmallV1.png": "7c7c137512ad3face7f3373ffcc1c1d7",
"assets/app_assets/block_images/loops/whileTrue/whileTrueSmallV2.png": "8ccb28c7c681511a387ce9e02c88b58d",
"assets/app_assets/block_images/startHere.png": "165a83b0b03d47db6edc23ce98ff60fb",
"assets/app_assets/block_images/statements/comment1.png": "a38d91302c6d2da6e1b72f93d0085eb6",
"assets/app_assets/block_images/statements/comment2.png": "22dfacfcf720618555b58d45f1d261d5",
"assets/app_assets/block_images/statements/print-calc.png": "e2c260c47309a83b0e32635a566cb2b5",
"assets/app_assets/block_images/statements/print-classes.png": "4dd5cec36fe790c63b0f29c8c88d9083",
"assets/app_assets/block_images/statements/print-reception.png": "d39c5db6a1951e9f9efb19641474f478",
"assets/app_assets/block_images/statements/print-seperator.png": "18c225ebc11e0367e8ed592e85ce001f",
"assets/app_assets/block_images/statements/print-unknown.png": "d8eef287bcb2c237f1c6995e0ef2be48",
"assets/app_assets/block_images/statements/print-variables-text.png": "01edd2f073b19972772d166a99fdb595",
"assets/app_assets/block_images/statements/print.png": "0e932094a7049c155815863f97fa0f4e",
"assets/app_assets/block_images/statements/print_favourite-fruit.png": "c430ca2dfebbdaf12c7f103807819e7a",
"assets/app_assets/block_images/statements/print_friends_0.png": "2b380130762a48b6ff3e514830e94455",
"assets/app_assets/block_images/statements/print_fruit-2.png": "86889ce7d28b36caf0365d21ebd40d2a",
"assets/app_assets/block_images/statements/print_fruit-3.png": "2e0be85ade4145161e619623353727c9",
"assets/app_assets/block_images/statements/print_fruits.png": "3ef43e1adcff33f31530f3aea441ae02",
"assets/app_assets/block_images/statements/print_high-school.png": "17c009405c1c698827e0d060b8cbfbf5",
"assets/app_assets/block_images/statements/print_my-friend-string.png": "827aedf1bd421ed43c707f3ca8e6ba28",
"assets/app_assets/block_images/statements/print_my-grades.png": "b9ebcdf4807338b9645789091e4cd395",
"assets/app_assets/block_images/statements/print_number1+number2.png": "c7f5878ed6dbb1300aab176878f76352",
"assets/app_assets/block_images/statements/print_primary-school.png": "cda76f014a47913c1358a7b2849d9d1b",
"assets/app_assets/block_images/statements/print_random-choice.png": "cde1721effb1e290f085ba0771578daa",
"assets/app_assets/block_images/statements/print_random-fruits.png": "16f63ed800dd3a7da0844e51da1fc639",
"assets/app_assets/block_images/statements/print_string.png": "67b406b074e5fc8ab5e71fbb1e704f91",
"assets/app_assets/block_images/statements/print_total-grades.png": "6d590471f08e9bb53cab9fba70a93635",
"assets/app_assets/block_images/statements/print_you-are-old.png": "d86a01875b60a17d296b0489165cf434",
"assets/app_assets/block_images/variables/age-variable_input.png": "3b2ed72a8638e6110c4cabb75c793569",
"assets/app_assets/block_images/variables/age10.png": "751931c4cd53e4eb56169248c2ed4cb3",
"assets/app_assets/block_images/variables/age14.png": "c4c9cc1fc95ba11e2420b0323e97a5bf",
"assets/app_assets/block_images/variables/age22.png": "e5b53e9c276c3bf065efb3543caf3fbd",
"assets/app_assets/block_images/variables/count+=1.png": "779d02ca601470f619e6c7a9fb2a89d8",
"assets/app_assets/block_images/variables/count=0.png": "f7ead23a53cbceef05e9a5f2e1fbe83c",
"assets/app_assets/block_images/variables/friends-list.png": "03dcfe6228e5bbb1400dd55674679d0d",
"assets/app_assets/block_images/variables/friends-variable.png": "8f40b637e92364fd3d21d6d4cf87bbdd",
"assets/app_assets/block_images/variables/fruits-list.png": "1c1074488ec34eed47b38f559a5d508e",
"assets/app_assets/block_images/variables/grade1.png": "76698b7efe4e7ae17978c067be4deb08",
"assets/app_assets/block_images/variables/grade2.png": "335193fd9bb94092f9149cae1801d565",
"assets/app_assets/block_images/variables/grade3.png": "7a31a5d4479d658d93676f5b1f91cff2",
"assets/app_assets/block_images/variables/grade4.png": "40c80208e098641df0609ea808bfe22d",
"assets/app_assets/block_images/variables/i_variable-plus-1.png": "f3424549ea9d4a9ab5a8a686b8a6f269",
"assets/app_assets/block_images/variables/i_variable.png": "dbfa8724e191ed693dd26164b0394cbe",
"assets/app_assets/block_images/variables/my-grades_list.png": "18bcb64e29f693d47d7cfdc3f902f894",
"assets/app_assets/block_images/variables/number1_variable.png": "92c7ba3d84c8572a2d5d716281741146",
"assets/app_assets/block_images/variables/number2_variable.png": "6e260edb960ecf74168754ca939d9af2",
"assets/app_assets/block_images/variables/total-grades.png": "4e42dc44488148968c8b372a16701970",
"assets/app_assets/block_images/variables/total-grades_to-int.png": "9439f9887809f5941fb5a04bbdde8a94",
"assets/app_assets/block_images/variables/variable-0.png": "ca5429445b09f5cc7099685123354b54",
"assets/app_assets/block_images/variables/variable-1.png": "3874ff9c6acfca9ac717d6d8b69fcd56",
"assets/app_assets/block_images/variables/variable-10.png": "c622bdecc5b14a53fc56f604cb3ff237",
"assets/app_assets/block_images/variables/variable-ash.png": "c554b7be34fe3bd3dd5106210bc99536",
"assets/app_assets/block_images/variables/variable-classes-list.png": "28e76ff8014490948bf111635be7eb6e",
"assets/app_assets/block_images/variables/variable-ks1-list.png": "239e639deb1441197ee683ef215fcb25",
"assets/app_assets/block_images/variables/variable-ks2-list.png": "7f3a82bd649de4cd2201e8e61c949ade",
"assets/app_assets/block_images/variables/variable2-increated.png": "c7933ce8bd924a91005a05930fa172b1",
"assets/app_assets/block_images/variables/variables-class-2.png": "dc3db3e59e75b8c146abcdc944f63484",
"assets/app_assets/categories.json": "5abdc29bc376cb4f331b5d5a0eecd24b",
"assets/app_assets/category_icons/arrows.svg": "153a2be7494629aabb838a80a1a2f0c4",
"assets/app_assets/category_icons/bars.svg": "04fb518fdcff49fc34022f3dab074b43",
"assets/app_assets/category_icons/exclamation.svg": "0c48d3c650d36c91480878eab2190c02",
"assets/app_assets/category_icons/flag.svg": "a0865837b8a07139d1c896cd1e8a7700",
"assets/app_assets/category_icons/list.svg": "d3927b86e7aff58aa0d012c4c9a81d35",
"assets/app_assets/category_icons/play.svg": "8e03205ba6239cf12dd2f4b853a60dd0",
"assets/app_assets/category_icons/rotateright.svg": "5c98debb875c6c9486314e186316fe74",
"assets/app_assets/category_icons/shuffle.svg": "87c2dcf84a1cf628d90e03b62c86156a",
"assets/app_assets/category_icons/squareroot.svg": "2c02e77ceaf4a99dc2b916a624ff459d",
"assets/app_assets/category_icons/textsize.svg": "74357cb361ca3e5c3d50b6615ee31dc2",
"assets/app_assets/category_icons/trash.svg": "b973ff8fcc8f3597e8c8d06b9e6026a6",
"assets/app_assets/category_icons/upload.svg": "5c072b4978ee571f29e16902482995e5",
"assets/app_assets/solutions.json": "f8ab0e4b3d4136a71fc4d1548ed37614",
"assets/app_assets/sounds/click.mp3": "f71910b391538a67231e088bba0d47eb",
"assets/app_assets/sounds/click.wav": "50ac7ca2a6522be84486a5a14afddd83",
"assets/app_assets/sounds/disconnect.wav": "409e7fabb73e895a642b9d3899d6ee7f",
"assets/AssetManifest.bin": "61ff3efa5c8bc3e304aef83ab1c1fa0d",
"assets/AssetManifest.bin.json": "d5a0583a9e5f1853adace401386aea31",
"assets/AssetManifest.json": "7ab0e89fdceeb3312c89ac4d13c9efbf",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "2dd28040cdebf61138ace6126bb7204e",
"assets/NOTICES": "91ddde03963e7ff4be31727784fc4dd1",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "3cae155a168d7a1bc7e5dd908b5e36c7",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d693cdaf8bafb491b6d5f0e1a0b40426",
"/": "d693cdaf8bafb491b6d5f0e1a0b40426",
"main.dart.js": "ec43706e129735adeb392abd40902340",
"manifest.json": "a01fba4dc1a36b15debc00c347f4b8c3",
"version.json": "054182236ce9f9f7c4866c56901a290c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
