// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DegenGambit} from "../src/DegenGambit.sol";

contract DegenGambitConfigurationTest is Test {
    DegenGambit public degenGambit;

    uint256 blocksToAct = 20;
    uint256 costToSpin = 0.1 ether;
    uint256 costToRespin = 0.07 ether;

    function setUp() public {
        degenGambit = new DegenGambit(blocksToAct, costToSpin, costToRespin);
    }

    function test_configuration() public view {
        assertEq(degenGambit.BlocksToAct(), blocksToAct);
        assertEq(degenGambit.CostToSpin(), costToSpin);
        assertEq(degenGambit.CostToRespin(), costToRespin);
    }

    function test_supportsInterface() public view {
        assertEq(degenGambit.supportsInterface(0x01ffc9a7), true);
        assertEq(degenGambit.supportsInterface(0x36372b07), true);
    }

    function test_version() public view {
        string memory version = degenGambit.version();
        assertEq(version, "1");
    }

    function test_ERC20Metadata() public view {
        assertEq(degenGambit.name(), "Degen's Gambit");
        assertEq(degenGambit.decimals(), 18);
        // Call the symbol function
        string memory symbol = degenGambit.symbol();

        // Ensure the symbol starts with "DG-"
        bytes memory prefix = bytes("DG-");
        for (uint i = 0; i < prefix.length; i++) {
            assertEq(
                bytes(symbol)[i],
                prefix[i],
                "Symbol prefix does not match 'DG-'"
            );
        }

        // Check if the suffix is a number between 0 and 9999
        string memory suffix = substring(symbol, 3, bytes(symbol).length); // Get the number part
        uint256 value = parseUint(suffix);

        // Assert the suffix number is within range
        assertTrue(
            value >= 0 && value < 10000,
            "Symbol suffix is out of expected range"
        );
    }

    // Helper function to parse a string to a uint
    function parseUint(string memory _a) internal pure returns (uint256) {
        bytes memory bresult = bytes(_a);
        uint256 result = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            if (uint8(bresult[i]) >= 48 && uint8(bresult[i]) <= 57) {
                result = result * 10 + (uint8(bresult[i]) - 48);
            }
        }
        return result;
    }

    // Helper function to extract substring
    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    // Test generated using the generate_sample_tests() function from the game design notebook
    function test_sampling_functions() public view {
        assertEq(degenGambit.sampleUnmodifiedLeftReel(0), 0);
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(28789306590710891878023168),
            0
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(14394653295355445939011584),
            0
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(28789307743632396484870144),
            1
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(28789307743632396484870144),
            1
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(143946519118496404107952128),
            1
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(86367913431064400296411136),
            1
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(28789306590710891878023168),
            0
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(143946520271417908714799104),
            2
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(143946520271417908714799104),
            2
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(201525125382389160222916608),
            2
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(172735822826903534468857856),
            2
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(143946519118496404107952128),
            1
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(201525126535310664829763584),
            3
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(201525126535310664829763584),
            3
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(259103731646281916337881088),
            3
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(230314429090796290583822336),
            3
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(201525125382389160222916608),
            2
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(259103732799203420944728064),
            4
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(259103732799203420944728064),
            4
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(374260944174067428567810048),
            4
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(316682338486635424756269056),
            4
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(259103731646281916337881088),
            3
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(374260945326988933174657024),
            5
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(374260945326988933174657024),
            5
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(431839550437960184682774528),
            5
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(403050247882474558928715776),
            5
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(374260944174067428567810048),
            4
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(431839551590881689289621504),
            6
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(431839551590881689289621504),
            6
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(489418156701852940797739008),
            6
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(460628854146367315043680256),
            6
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(431839550437960184682774528),
            5
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(489418157854774445404585984),
            7
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(489418157854774445404585984),
            7
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(604575369229638453027667968),
            7
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(546996763542206449216126976),
            7
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(489418156701852940797739008),
            6
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(604575370382559957634514944),
            8
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(604575370382559957634514944),
            8
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(662153975493531209142632448),
            8
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(633364672938045583388573696),
            8
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(604575369229638453027667968),
            7
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(662153976646452713749479424),
            9
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(662153976646452713749479424),
            9
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(719732581757423965257596928),
            9
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(690943279201938339503538176),
            9
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(662153975493531209142632448),
            8
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(719732582910345469864443904),
            10
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(719732582910345469864443904),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(834889794285209477487525888),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(777311188597777473675984896),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(719732581757423965257596928),
            9
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(834889795438130982094372864),
            11
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(834889795438130982094372864),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(892468400549102233602490368),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(863679097993616607848431616),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(834889794285209477487525888),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(892468401702023738209337344),
            12
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(892468401702023738209337344),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(950047006812994989717454848),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(921257704257509363963396096),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(892468400549102233602490368),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(950047007965916494324301824),
            13
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(950047007965916494324301824),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1065204219340780501947383808),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1007625613653348498135842816),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(950047006812994989717454848),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1065204220493702006554230784),
            14
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1065204220493702006554230784),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1122782825604673258062348288),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1093993523049187632308289536),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1065204219340780501947383808),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1122782826757594762669195264),
            15
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1122782826757594762669195264),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1180361431868566014177312768),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1151572129313080388423254016),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1122782825604673258062348288),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1180361433021487518784159744),
            16
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1180361433021487518784159744),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1209150735000512392234795008),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1194756084010999955509477376),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1180361431868566014177312768),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1209150736153433896841641984),
            17
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1209150736153433896841641984),
            17
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1223545386566485581263536128),
            17
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1216348061359959739052589056),
            17
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1209150735000512392234795008),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1223545387719407085870383104),
            18
        );

        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1223545387719407085870383104),
            18
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1237940038132458770292277248),
            18
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1230742712925932928081330176),
            18
        );
        assertEq(
            degenGambit.sampleUnmodifiedLeftReel(1223545386566485581263536128),
            17
        );

        assertEq(degenGambit.sampleUnmodifiedCenterReel(0), 0);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(26812131135455232), 0);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(13406065567727616), 0);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(26812132209197056), 1);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(26812132209197056), 1);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(80436386963914752), 1);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(53624259586555904), 1);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(26812131135455232), 0);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(80436388037656576), 2);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(80436388037656576), 2);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(187684898620833792), 2);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(134060643329245184), 2);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(80436386963914752), 1);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(187684899694575616), 3);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(187684899694575616), 3);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(241309154449293312), 3);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(214497027071934464), 3);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(187684898620833792), 2);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(241309155523035136), 4);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(241309155523035136), 4);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(294933410277752832), 4);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(268121282900393984), 4);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(241309154449293312), 3);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(294933411351494656), 5);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(294933411351494656), 5);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(402181921934671872), 5);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(348557666643083264), 5);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(294933410277752832), 4);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(402181923008413696), 6);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(402181923008413696), 6);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(455806177763131392), 6);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(428994050385772544), 6);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(402181921934671872), 5);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(455806178836873216), 7);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(455806178836873216), 7);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(509430433591590912), 7);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(482618306214232064), 7);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(455806177763131392), 6);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(509430434665332736), 8);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(509430434665332736), 8);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(616678945248509952), 8);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(563054689956921344), 8);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(509430433591590912), 7);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(616678946322251776), 9);

        assertEq(degenGambit.sampleUnmodifiedCenterReel(616678946322251776), 9);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(670303201076969472), 9);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(643491073699610624), 9);
        assertEq(degenGambit.sampleUnmodifiedCenterReel(616678945248509952), 8);
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(670303202150711296),
            10
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(670303202150711296),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(723927456905428992),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(697115329528070144),
            10
        );
        assertEq(degenGambit.sampleUnmodifiedCenterReel(670303201076969472), 9);
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(723927457979170816),
            11
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(723927457979170816),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(831175968562348032),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(777551713270759424),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(723927456905428992),
            10
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(831175969636089856),
            12
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(831175969636089856),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(884800224390807552),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(857988097013448704),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(831175968562348032),
            11
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(884800225464549376),
            13
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(884800225464549376),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(938424480219267072),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(911612352841908224),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(884800224390807552),
            12
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(938424481293008896),
            14
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(938424481293008896),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1045672991876186112),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(992048736584597504),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(938424480219267072),
            13
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1045672992949927936),
            15
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1045672992949927936),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1099297247704645632),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1072485120327286784),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1045672991876186112),
            14
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1099297248778387456),
            16
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1099297248778387456),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1112703311661760512),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1106000280220073984),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1099297247704645632),
            15
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1112703312735502336),
            17
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1112703312735502336),
            17
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1139515439575990272),
            17
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1126109376155746304),
            17
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1112703311661760512),
            16
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1139515440649732096),
            18
        );

        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1139515440649732096),
            18
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1152921503533105152),
            18
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1146218472091418624),
            18
        );
        assertEq(
            degenGambit.sampleUnmodifiedCenterReel(1139515439575990272),
            17
        );

        assertEq(degenGambit.sampleUnmodifiedRightReel(0), 0);
        assertEq(degenGambit.sampleUnmodifiedRightReel(24970743), 0);
        assertEq(degenGambit.sampleUnmodifiedRightReel(12485371), 0);
        assertEq(degenGambit.sampleUnmodifiedRightReel(24970744), 1);

        assertEq(degenGambit.sampleUnmodifiedRightReel(24970744), 1);
        assertEq(degenGambit.sampleUnmodifiedRightReel(74912223), 1);
        assertEq(degenGambit.sampleUnmodifiedRightReel(49941483), 1);
        assertEq(degenGambit.sampleUnmodifiedRightReel(24970743), 0);
        assertEq(degenGambit.sampleUnmodifiedRightReel(74912224), 2);

        assertEq(degenGambit.sampleUnmodifiedRightReel(74912224), 2);
        assertEq(degenGambit.sampleUnmodifiedRightReel(124853703), 2);
        assertEq(degenGambit.sampleUnmodifiedRightReel(99882963), 2);
        assertEq(degenGambit.sampleUnmodifiedRightReel(74912223), 1);
        assertEq(degenGambit.sampleUnmodifiedRightReel(124853704), 3);

        assertEq(degenGambit.sampleUnmodifiedRightReel(124853704), 3);
        assertEq(degenGambit.sampleUnmodifiedRightReel(224736663), 3);
        assertEq(degenGambit.sampleUnmodifiedRightReel(174795183), 3);
        assertEq(degenGambit.sampleUnmodifiedRightReel(124853703), 2);
        assertEq(degenGambit.sampleUnmodifiedRightReel(224736664), 4);

        assertEq(degenGambit.sampleUnmodifiedRightReel(224736664), 4);
        assertEq(degenGambit.sampleUnmodifiedRightReel(274678143), 4);
        assertEq(degenGambit.sampleUnmodifiedRightReel(249707403), 4);
        assertEq(degenGambit.sampleUnmodifiedRightReel(224736663), 3);
        assertEq(degenGambit.sampleUnmodifiedRightReel(274678144), 5);

        assertEq(degenGambit.sampleUnmodifiedRightReel(274678144), 5);
        assertEq(degenGambit.sampleUnmodifiedRightReel(324619623), 5);
        assertEq(degenGambit.sampleUnmodifiedRightReel(299648883), 5);
        assertEq(degenGambit.sampleUnmodifiedRightReel(274678143), 4);
        assertEq(degenGambit.sampleUnmodifiedRightReel(324619624), 6);

        assertEq(degenGambit.sampleUnmodifiedRightReel(324619624), 6);
        assertEq(degenGambit.sampleUnmodifiedRightReel(424502583), 6);
        assertEq(degenGambit.sampleUnmodifiedRightReel(374561103), 6);
        assertEq(degenGambit.sampleUnmodifiedRightReel(324619623), 5);
        assertEq(degenGambit.sampleUnmodifiedRightReel(424502584), 7);

        assertEq(degenGambit.sampleUnmodifiedRightReel(424502584), 7);
        assertEq(degenGambit.sampleUnmodifiedRightReel(474444063), 7);
        assertEq(degenGambit.sampleUnmodifiedRightReel(449473323), 7);
        assertEq(degenGambit.sampleUnmodifiedRightReel(424502583), 6);
        assertEq(degenGambit.sampleUnmodifiedRightReel(474444064), 8);

        assertEq(degenGambit.sampleUnmodifiedRightReel(474444064), 8);
        assertEq(degenGambit.sampleUnmodifiedRightReel(524385543), 8);
        assertEq(degenGambit.sampleUnmodifiedRightReel(499414803), 8);
        assertEq(degenGambit.sampleUnmodifiedRightReel(474444063), 7);
        assertEq(degenGambit.sampleUnmodifiedRightReel(524385544), 9);

        assertEq(degenGambit.sampleUnmodifiedRightReel(524385544), 9);
        assertEq(degenGambit.sampleUnmodifiedRightReel(624268503), 9);
        assertEq(degenGambit.sampleUnmodifiedRightReel(574327023), 9);
        assertEq(degenGambit.sampleUnmodifiedRightReel(524385543), 8);
        assertEq(degenGambit.sampleUnmodifiedRightReel(624268504), 10);

        assertEq(degenGambit.sampleUnmodifiedRightReel(624268504), 10);
        assertEq(degenGambit.sampleUnmodifiedRightReel(674209983), 10);
        assertEq(degenGambit.sampleUnmodifiedRightReel(649239243), 10);
        assertEq(degenGambit.sampleUnmodifiedRightReel(624268503), 9);
        assertEq(degenGambit.sampleUnmodifiedRightReel(674209984), 11);

        assertEq(degenGambit.sampleUnmodifiedRightReel(674209984), 11);
        assertEq(degenGambit.sampleUnmodifiedRightReel(724151463), 11);
        assertEq(degenGambit.sampleUnmodifiedRightReel(699180723), 11);
        assertEq(degenGambit.sampleUnmodifiedRightReel(674209983), 10);
        assertEq(degenGambit.sampleUnmodifiedRightReel(724151464), 12);

        assertEq(degenGambit.sampleUnmodifiedRightReel(724151464), 12);
        assertEq(degenGambit.sampleUnmodifiedRightReel(824034423), 12);
        assertEq(degenGambit.sampleUnmodifiedRightReel(774092943), 12);
        assertEq(degenGambit.sampleUnmodifiedRightReel(724151463), 11);
        assertEq(degenGambit.sampleUnmodifiedRightReel(824034424), 13);

        assertEq(degenGambit.sampleUnmodifiedRightReel(824034424), 13);
        assertEq(degenGambit.sampleUnmodifiedRightReel(873975903), 13);
        assertEq(degenGambit.sampleUnmodifiedRightReel(849005163), 13);
        assertEq(degenGambit.sampleUnmodifiedRightReel(824034423), 12);
        assertEq(degenGambit.sampleUnmodifiedRightReel(873975904), 14);

        assertEq(degenGambit.sampleUnmodifiedRightReel(873975904), 14);
        assertEq(degenGambit.sampleUnmodifiedRightReel(923917383), 14);
        assertEq(degenGambit.sampleUnmodifiedRightReel(898946643), 14);
        assertEq(degenGambit.sampleUnmodifiedRightReel(873975903), 13);
        assertEq(degenGambit.sampleUnmodifiedRightReel(923917384), 15);

        assertEq(degenGambit.sampleUnmodifiedRightReel(923917384), 15);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1023800343), 15);
        assertEq(degenGambit.sampleUnmodifiedRightReel(973858863), 15);
        assertEq(degenGambit.sampleUnmodifiedRightReel(923917383), 14);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1023800344), 16);

        assertEq(degenGambit.sampleUnmodifiedRightReel(1023800344), 16);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1036285713), 16);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1030043028), 16);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1023800343), 15);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1036285714), 17);

        assertEq(degenGambit.sampleUnmodifiedRightReel(1036285714), 17);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1048771083), 17);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1042528398), 17);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1036285713), 16);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1048771084), 18);

        assertEq(degenGambit.sampleUnmodifiedRightReel(1048771084), 18);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1073741823), 18);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1061256453), 18);
        assertEq(degenGambit.sampleUnmodifiedRightReel(1048771083), 17);

        assertEq(degenGambit.sampleImprovedLeftReel(0), 0);
        assertEq(
            degenGambit.sampleImprovedLeftReel(2912755877218298089177088),
            0
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1456377938609149044588544),
            0
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(2912757030139802696024064),
            1
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(2912757030139802696024064),
            1
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(120589358994065298288541696),
            1
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(61751058012102550492282880),
            1
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(2912755877218298089177088),
            0
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(120589360146986802895388672),
            2
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(120589360146986802895388672),
            2
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(179427632305911935520473088),
            2
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(150008496226449369207930880),
            2
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(120589358994065298288541696),
            1
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(179427633458833440127320064),
            3
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(179427633458833440127320064),
            3
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(238265905617758572752404480),
            3
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(208846769538296006439862272),
            3
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(179427632305911935520473088),
            2
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(238265906770680077359251456),
            4
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(238265906770680077359251456),
            4
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(355942508734605572951769088),
            4
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(297104207752642825155510272),
            4
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(238265905617758572752404480),
            3
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(355942509887527077558616064),
            5
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(355942509887527077558616064),
            5
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(414780782046452210183700480),
            5
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(385361645966989643871158272),
            5
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(355942508734605572951769088),
            4
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(414780783199373714790547456),
            6
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(414780783199373714790547456),
            6
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(473619055358298847415631872),
            6
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(444199919278836281103089664),
            6
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(414780782046452210183700480),
            5
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(473619056511220352022478848),
            7
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(473619056511220352022478848),
            7
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(591295658475145847614996480),
            7
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(532457357493183099818737664),
            7
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(473619055358298847415631872),
            6
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(591295659628067352221843456),
            8
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(591295659628067352221843456),
            8
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(650133931786992484846927872),
            8
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(620714795707529918534385664),
            8
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(591295658475145847614996480),
            7
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(650133932939913989453774848),
            9
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(650133932939913989453774848),
            9
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(708972205098839122078859264),
            9
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(679553069019376555766317056),
            9
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(650133931786992484846927872),
            8
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(708972206251760626685706240),
            10
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(708972206251760626685706240),
            10
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(826648808215686122278223872),
            10
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(767810507233723374481965056),
            10
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(708972205098839122078859264),
            9
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(826648809368607626885070848),
            11
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(826648809368607626885070848),
            11
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(885487081527532759510155264),
            11
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(856067945448070193197613056),
            11
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(826648808215686122278223872),
            10
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(885487082680454264117002240),
            12
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(885487082680454264117002240),
            12
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(944325354839379396742086656),
            12
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(914906218759916830429544448),
            12
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(885487081527532759510155264),
            11
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(944325355992300901348933632),
            13
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(944325355992300901348933632),
            13
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1062001957956226396941451264),
            13
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1003163656974263649145192448),
            13
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(944325354839379396742086656),
            12
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1062001959109147901548298240),
            14
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(1062001959109147901548298240),
            14
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1120840231268073034173382656),
            14
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1091421095188610467860840448),
            14
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1062001957956226396941451264),
            13
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1120840232420994538780229632),
            15
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(1120840232420994538780229632),
            15
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1179678504579919671405314048),
            15
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1150259368500457105092771840),
            15
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1120840231268073034173382656),
            14
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1179678505732841176012161024),
            16
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(1179678505732841176012161024),
            16
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1208809271932649973152219136),
            16
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1194243888832745574582190080),
            16
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1179678504579919671405314048),
            15
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1208809273085571477759066112),
            17
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(1208809273085571477759066112),
            17
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1223374655032554371722248192),
            17
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1216091964059062924740657152),
            17
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1208809271932649973152219136),
            16
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1223374656185475876329095168),
            18
        );

        assertEq(
            degenGambit.sampleImprovedLeftReel(1223374656185475876329095168),
            18
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1237940038132458770292277248),
            18
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1230657347158967323310686208),
            18
        );
        assertEq(
            degenGambit.sampleImprovedLeftReel(1223374655032554371722248192),
            17
        );

        assertEq(degenGambit.sampleImprovedCenterReel(0), 0);
        assertEq(degenGambit.sampleImprovedCenterReel(2712715302797312), 0);
        assertEq(degenGambit.sampleImprovedCenterReel(1356357651398656), 0);
        assertEq(degenGambit.sampleImprovedCenterReel(2712716376539136), 1);

        assertEq(degenGambit.sampleImprovedCenterReel(2712716376539136), 1);
        assertEq(degenGambit.sampleImprovedCenterReel(57510127489515520), 1);
        assertEq(degenGambit.sampleImprovedCenterReel(30111421933027328), 1);
        assertEq(degenGambit.sampleImprovedCenterReel(2712715302797312), 0);
        assertEq(degenGambit.sampleImprovedCenterReel(57510128563257344), 2);

        assertEq(degenGambit.sampleImprovedCenterReel(57510128563257344), 2);
        assertEq(degenGambit.sampleImprovedCenterReel(167105004476301312), 2);
        assertEq(degenGambit.sampleImprovedCenterReel(112307566519779328), 2);
        assertEq(degenGambit.sampleImprovedCenterReel(57510127489515520), 1);
        assertEq(degenGambit.sampleImprovedCenterReel(167105005550043136), 3);

        assertEq(degenGambit.sampleImprovedCenterReel(167105005550043136), 3);
        assertEq(degenGambit.sampleImprovedCenterReel(221902416663019520), 3);
        assertEq(degenGambit.sampleImprovedCenterReel(194503711106531328), 3);
        assertEq(degenGambit.sampleImprovedCenterReel(167105004476301312), 2);
        assertEq(degenGambit.sampleImprovedCenterReel(221902417736761344), 4);

        assertEq(degenGambit.sampleImprovedCenterReel(221902417736761344), 4);
        assertEq(degenGambit.sampleImprovedCenterReel(276699828849737728), 4);
        assertEq(degenGambit.sampleImprovedCenterReel(249301123293249536), 4);
        assertEq(degenGambit.sampleImprovedCenterReel(221902416663019520), 3);
        assertEq(degenGambit.sampleImprovedCenterReel(276699829923479552), 5);

        assertEq(degenGambit.sampleImprovedCenterReel(276699829923479552), 5);
        assertEq(degenGambit.sampleImprovedCenterReel(386294705836523520), 5);
        assertEq(degenGambit.sampleImprovedCenterReel(331497267880001536), 5);
        assertEq(degenGambit.sampleImprovedCenterReel(276699828849737728), 4);
        assertEq(degenGambit.sampleImprovedCenterReel(386294706910265344), 6);

        assertEq(degenGambit.sampleImprovedCenterReel(386294706910265344), 6);
        assertEq(degenGambit.sampleImprovedCenterReel(441092118023241728), 6);
        assertEq(degenGambit.sampleImprovedCenterReel(413693412466753536), 6);
        assertEq(degenGambit.sampleImprovedCenterReel(386294705836523520), 5);
        assertEq(degenGambit.sampleImprovedCenterReel(441092119096983552), 7);

        assertEq(degenGambit.sampleImprovedCenterReel(441092119096983552), 7);
        assertEq(degenGambit.sampleImprovedCenterReel(495889530209959936), 7);
        assertEq(degenGambit.sampleImprovedCenterReel(468490824653471744), 7);
        assertEq(degenGambit.sampleImprovedCenterReel(441092118023241728), 6);
        assertEq(degenGambit.sampleImprovedCenterReel(495889531283701760), 8);

        assertEq(degenGambit.sampleImprovedCenterReel(495889531283701760), 8);
        assertEq(degenGambit.sampleImprovedCenterReel(605484407196745728), 8);
        assertEq(degenGambit.sampleImprovedCenterReel(550686969240223744), 8);
        assertEq(degenGambit.sampleImprovedCenterReel(495889530209959936), 7);
        assertEq(degenGambit.sampleImprovedCenterReel(605484408270487552), 9);

        assertEq(degenGambit.sampleImprovedCenterReel(605484408270487552), 9);
        assertEq(degenGambit.sampleImprovedCenterReel(660281819383463936), 9);
        assertEq(degenGambit.sampleImprovedCenterReel(632883113826975744), 9);
        assertEq(degenGambit.sampleImprovedCenterReel(605484407196745728), 8);
        assertEq(degenGambit.sampleImprovedCenterReel(660281820457205760), 10);

        assertEq(degenGambit.sampleImprovedCenterReel(660281820457205760), 10);
        assertEq(degenGambit.sampleImprovedCenterReel(715079231570182144), 10);
        assertEq(degenGambit.sampleImprovedCenterReel(687680526013693952), 10);
        assertEq(degenGambit.sampleImprovedCenterReel(660281819383463936), 9);
        assertEq(degenGambit.sampleImprovedCenterReel(715079232643923968), 11);

        assertEq(degenGambit.sampleImprovedCenterReel(715079232643923968), 11);
        assertEq(degenGambit.sampleImprovedCenterReel(824674108556967936), 11);
        assertEq(degenGambit.sampleImprovedCenterReel(769876670600445952), 11);
        assertEq(degenGambit.sampleImprovedCenterReel(715079231570182144), 10);
        assertEq(degenGambit.sampleImprovedCenterReel(824674109630709760), 12);

        assertEq(degenGambit.sampleImprovedCenterReel(824674109630709760), 12);
        assertEq(degenGambit.sampleImprovedCenterReel(879471520743686144), 12);
        assertEq(degenGambit.sampleImprovedCenterReel(852072815187197952), 12);
        assertEq(degenGambit.sampleImprovedCenterReel(824674108556967936), 11);
        assertEq(degenGambit.sampleImprovedCenterReel(879471521817427968), 13);

        assertEq(degenGambit.sampleImprovedCenterReel(879471521817427968), 13);
        assertEq(degenGambit.sampleImprovedCenterReel(934268932930404352), 13);
        assertEq(degenGambit.sampleImprovedCenterReel(906870227373916160), 13);
        assertEq(degenGambit.sampleImprovedCenterReel(879471520743686144), 12);
        assertEq(degenGambit.sampleImprovedCenterReel(934268934004146176), 14);

        assertEq(degenGambit.sampleImprovedCenterReel(934268934004146176), 14);
        assertEq(degenGambit.sampleImprovedCenterReel(1043863809917190144), 14);
        assertEq(degenGambit.sampleImprovedCenterReel(989066371960668160), 14);
        assertEq(degenGambit.sampleImprovedCenterReel(934268932930404352), 13);
        assertEq(degenGambit.sampleImprovedCenterReel(1043863810990931968), 15);

        assertEq(degenGambit.sampleImprovedCenterReel(1043863810990931968), 15);
        assertEq(degenGambit.sampleImprovedCenterReel(1098661222103908352), 15);
        assertEq(degenGambit.sampleImprovedCenterReel(1071262516547420160), 15);
        assertEq(degenGambit.sampleImprovedCenterReel(1043863809917190144), 14);
        assertEq(degenGambit.sampleImprovedCenterReel(1098661223177650176), 16);

        assertEq(degenGambit.sampleImprovedCenterReel(1098661223177650176), 16);
        assertEq(degenGambit.sampleImprovedCenterReel(1112226292192772096), 16);
        assertEq(degenGambit.sampleImprovedCenterReel(1105443757685211136), 16);
        assertEq(degenGambit.sampleImprovedCenterReel(1098661222103908352), 15);
        assertEq(degenGambit.sampleImprovedCenterReel(1112226293266513920), 17);

        assertEq(degenGambit.sampleImprovedCenterReel(1112226293266513920), 17);
        assertEq(degenGambit.sampleImprovedCenterReel(1139356433444241408), 17);
        assertEq(degenGambit.sampleImprovedCenterReel(1125791363355377664), 17);
        assertEq(degenGambit.sampleImprovedCenterReel(1112226292192772096), 16);
        assertEq(degenGambit.sampleImprovedCenterReel(1139356434517983232), 18);

        assertEq(degenGambit.sampleImprovedCenterReel(1139356434517983232), 18);
        assertEq(degenGambit.sampleImprovedCenterReel(1152921503533105152), 18);
        assertEq(degenGambit.sampleImprovedCenterReel(1146138969025544192), 18);
        assertEq(degenGambit.sampleImprovedCenterReel(1139356433444241408), 17);

        assertEq(degenGambit.sampleImprovedRightReel(0), 0);
        assertEq(degenGambit.sampleImprovedRightReel(2526413), 0);
        assertEq(degenGambit.sampleImprovedRightReel(1263206), 0);
        assertEq(degenGambit.sampleImprovedRightReel(2526414), 1);

        assertEq(degenGambit.sampleImprovedRightReel(2526414), 1);
        assertEq(degenGambit.sampleImprovedRightReel(53560480), 1);
        assertEq(degenGambit.sampleImprovedRightReel(28043447), 1);
        assertEq(degenGambit.sampleImprovedRightReel(2526413), 0);
        assertEq(degenGambit.sampleImprovedRightReel(53560481), 2);

        assertEq(degenGambit.sampleImprovedRightReel(53560481), 2);
        assertEq(degenGambit.sampleImprovedRightReel(104594547), 2);
        assertEq(degenGambit.sampleImprovedRightReel(79077514), 2);
        assertEq(degenGambit.sampleImprovedRightReel(53560480), 1);
        assertEq(degenGambit.sampleImprovedRightReel(104594548), 3);

        assertEq(degenGambit.sampleImprovedRightReel(104594548), 3);
        assertEq(degenGambit.sampleImprovedRightReel(206662730), 3);
        assertEq(degenGambit.sampleImprovedRightReel(155628639), 3);
        assertEq(degenGambit.sampleImprovedRightReel(104594547), 2);
        assertEq(degenGambit.sampleImprovedRightReel(206662731), 4);

        assertEq(degenGambit.sampleImprovedRightReel(206662731), 4);
        assertEq(degenGambit.sampleImprovedRightReel(257696797), 4);
        assertEq(degenGambit.sampleImprovedRightReel(232179764), 4);
        assertEq(degenGambit.sampleImprovedRightReel(206662730), 3);
        assertEq(degenGambit.sampleImprovedRightReel(257696798), 5);

        assertEq(degenGambit.sampleImprovedRightReel(257696798), 5);
        assertEq(degenGambit.sampleImprovedRightReel(308730864), 5);
        assertEq(degenGambit.sampleImprovedRightReel(283213831), 5);
        assertEq(degenGambit.sampleImprovedRightReel(257696797), 4);
        assertEq(degenGambit.sampleImprovedRightReel(308730865), 6);

        assertEq(degenGambit.sampleImprovedRightReel(308730865), 6);
        assertEq(degenGambit.sampleImprovedRightReel(410799047), 6);
        assertEq(degenGambit.sampleImprovedRightReel(359764956), 6);
        assertEq(degenGambit.sampleImprovedRightReel(308730864), 5);
        assertEq(degenGambit.sampleImprovedRightReel(410799048), 7);

        assertEq(degenGambit.sampleImprovedRightReel(410799048), 7);
        assertEq(degenGambit.sampleImprovedRightReel(461833114), 7);
        assertEq(degenGambit.sampleImprovedRightReel(436316081), 7);
        assertEq(degenGambit.sampleImprovedRightReel(410799047), 6);
        assertEq(degenGambit.sampleImprovedRightReel(461833115), 8);

        assertEq(degenGambit.sampleImprovedRightReel(461833115), 8);
        assertEq(degenGambit.sampleImprovedRightReel(512867181), 8);
        assertEq(degenGambit.sampleImprovedRightReel(487350148), 8);
        assertEq(degenGambit.sampleImprovedRightReel(461833114), 7);
        assertEq(degenGambit.sampleImprovedRightReel(512867182), 9);

        assertEq(degenGambit.sampleImprovedRightReel(512867182), 9);
        assertEq(degenGambit.sampleImprovedRightReel(614935364), 9);
        assertEq(degenGambit.sampleImprovedRightReel(563901273), 9);
        assertEq(degenGambit.sampleImprovedRightReel(512867181), 8);
        assertEq(degenGambit.sampleImprovedRightReel(614935365), 10);

        assertEq(degenGambit.sampleImprovedRightReel(614935365), 10);
        assertEq(degenGambit.sampleImprovedRightReel(665969431), 10);
        assertEq(degenGambit.sampleImprovedRightReel(640452398), 10);
        assertEq(degenGambit.sampleImprovedRightReel(614935364), 9);
        assertEq(degenGambit.sampleImprovedRightReel(665969432), 11);

        assertEq(degenGambit.sampleImprovedRightReel(665969432), 11);
        assertEq(degenGambit.sampleImprovedRightReel(717003498), 11);
        assertEq(degenGambit.sampleImprovedRightReel(691486465), 11);
        assertEq(degenGambit.sampleImprovedRightReel(665969431), 10);
        assertEq(degenGambit.sampleImprovedRightReel(717003499), 12);

        assertEq(degenGambit.sampleImprovedRightReel(717003499), 12);
        assertEq(degenGambit.sampleImprovedRightReel(819071681), 12);
        assertEq(degenGambit.sampleImprovedRightReel(768037590), 12);
        assertEq(degenGambit.sampleImprovedRightReel(717003498), 11);
        assertEq(degenGambit.sampleImprovedRightReel(819071682), 13);

        assertEq(degenGambit.sampleImprovedRightReel(819071682), 13);
        assertEq(degenGambit.sampleImprovedRightReel(870105748), 13);
        assertEq(degenGambit.sampleImprovedRightReel(844588715), 13);
        assertEq(degenGambit.sampleImprovedRightReel(819071681), 12);
        assertEq(degenGambit.sampleImprovedRightReel(870105749), 14);

        assertEq(degenGambit.sampleImprovedRightReel(870105749), 14);
        assertEq(degenGambit.sampleImprovedRightReel(921139815), 14);
        assertEq(degenGambit.sampleImprovedRightReel(895622782), 14);
        assertEq(degenGambit.sampleImprovedRightReel(870105748), 13);
        assertEq(degenGambit.sampleImprovedRightReel(921139816), 15);

        assertEq(degenGambit.sampleImprovedRightReel(921139816), 15);
        assertEq(degenGambit.sampleImprovedRightReel(1023207998), 15);
        assertEq(degenGambit.sampleImprovedRightReel(972173907), 15);
        assertEq(degenGambit.sampleImprovedRightReel(921139815), 14);
        assertEq(degenGambit.sampleImprovedRightReel(1023207999), 16);

        assertEq(degenGambit.sampleImprovedRightReel(1023207999), 16);
        assertEq(degenGambit.sampleImprovedRightReel(1035841454), 16);
        assertEq(degenGambit.sampleImprovedRightReel(1029524726), 16);
        assertEq(degenGambit.sampleImprovedRightReel(1023207998), 15);
        assertEq(degenGambit.sampleImprovedRightReel(1035841455), 17);

        assertEq(degenGambit.sampleImprovedRightReel(1035841455), 17);
        assertEq(degenGambit.sampleImprovedRightReel(1048474910), 17);
        assertEq(degenGambit.sampleImprovedRightReel(1042158182), 17);
        assertEq(degenGambit.sampleImprovedRightReel(1035841454), 16);
        assertEq(degenGambit.sampleImprovedRightReel(1048474911), 18);

        assertEq(degenGambit.sampleImprovedRightReel(1048474911), 18);
        assertEq(degenGambit.sampleImprovedRightReel(1073741823), 18);
        assertEq(degenGambit.sampleImprovedRightReel(1061108367), 18);
        assertEq(degenGambit.sampleImprovedRightReel(1048474910), 17);
    }

    // Test generated by the generate_outcome_tests function in the game design notebook using the following parameters:
    // generate_outcome_tests(16, 16, 16, 42, False)
    function test_16_16_16_42_False() public view {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084106756314349564952,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084106756314355807636,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084106756314362050321,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084113459345254380568,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084113459345260623252,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084113459345266865937,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084120162377232938008,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084120162377239180692,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173843084120162377245423377,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734519807998771459096,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734519807998777701780,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734519807998783944465,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734526511029676274712,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734526511029682517396,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734526511029688760081,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734533214061654832152,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734533214061661074836,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53188237734533214061667317521,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386085781187800200216,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386085781187806442900,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386085781187812685585,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386092484218705015832,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386092484218711258516,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386092484218717501201,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386099187250683573272,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386099187250689815956,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202632386099187250696058641,
            false
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);
    }

    // Test generated by the generate_outcome_tests function in the game design notebook using the following parameters:
    // generate_outcome_tests(16, 16, 16, 42, True)
    function test_16_16_16_42_True() public view {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156817473945976236607,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156817473945982553334,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156817473945988870062,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156824256479946926655,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156824256479953243382,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156824256479959560110,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039014991358527,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039014997675254,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039015003991982,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539917378344546265663,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539917378344552582390,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539917378344558899118,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539924160878516955711,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539924160878523272438,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539924160878529589166,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943413561387583,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943413567704310,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943413574021038,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923017282743116294719,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923017282743122611446,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923017282743128928174,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923024065277086984767,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923024065277093301494,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923024065277099618222,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847812131416639,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847812137733366,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847812144050094,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);
    }

    // Test generated by the generate_outcome_tests function in the game design notebook using the following parameters:
    // generate_outcome_tests(17, 16, 16, 42, True)
    function test_17_16_16_42_True() public view {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924170204247723141695,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924170204247729458422,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924170204247735775150,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924176986781693831743,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924176986781700148470,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924176986781706465198,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924183769316738263615,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924183769316744580342,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290924183769316750897070,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614567234942401309247,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614567234942407625974,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614567234942413942702,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614574017476371999295,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614574017476378316022,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614574017476384632750,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614580800011416431167,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614580800011422747894,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53209573614580800011429064622,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306117187141686323775,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306117187141692640502,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306117187141698957230,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306123969675657013823,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306123969675663330550,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306123969675669647278,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306130752210701445695,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306130752210707762422,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53216856306130752210714079150,
            true
        );
        assertEq(left, 17);
        assertEq(center, 16);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);
    }

    // Test generated by the generate_outcome_tests function in the game design notebook using the following parameters:
    // generate_outcome_tests(16, 17, 16, 42, True)
    function test_16_17_16_42_True() public view {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039016065100351,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039016071417078,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039016077733806,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156844604086153964095,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156844604086160280822,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156844604086166597550,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156858169156242827839,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156858169156249144566,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156858169156255461294,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943414635129407,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943414641446134,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943414647762862,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539944508484723993151,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539944508484730309878,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539944508484736626606,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539958073554812856895,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539958073554819173622,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539958073554825490350,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847813205158463,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847813211475190,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847813217791918,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923044412883294022207,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923044412883300338934,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923044412883306655662,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923057977953382885951,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923057977953389202678,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923057977953395519406,
            true
        );
        assertEq(left, 16);
        assertEq(center, 17);
        assertEq(right, 16);
        assertEq(remainingEntropy, 42);
    }

    // Test generated by the generate_outcome_tests function in the game design notebook using the following parameters:
    // generate_outcome_tests(16, 16, 17, 42, True)
    function test_16_16_17_42_True() public view {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156817473945988870063,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156817473945995186790,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156817473946001503518,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156824256479959560111,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156824256479965876838,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156824256479972193566,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039015003991983,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039015010308710,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53173160156831039015016625438,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539917378344558899119,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539917378344565215846,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539917378344571532574,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539924160878529589167,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539924160878535905894,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539924160878542222622,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943413574021039,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943413580337766,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53187725539930943413586654494,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923017282743128928175,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923017282743135244902,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923017282743141561630,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923024065277099618223,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923024065277105934950,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923024065277112251678,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847812144050095,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847812150366822,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            53202290923030847812156683550,
            true
        );
        assertEq(left, 16);
        assertEq(center, 16);
        assertEq(right, 17);
        assertEq(remainingEntropy, 42);
    }

    // Test generated by the generate_outcome_tests function in the game design notebook using the following parameters:
    // generate_outcome_tests(5, 0, 12, 42, True)
    function test_5_0_12_42_True() public view {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159873498624038836971,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159873498624089871062,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159873498624140905153,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159874854981153364715,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159874854981204398806,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159874854981255432897,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159876211339341634283,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159876211339392668374,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52349424159876211339443702465,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295952961190351379179,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295952961190402413270,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295952961190453447361,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295954317547465906923,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295954317547516941014,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295954317547567975105,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295955673905654176491,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295955673905705210582,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52378843295955673905756244673,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432032423756663921387,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432032423756714955478,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432032423756765989569,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432033780113778449131,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432033780113829483222,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432033780113880517313,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432035136471966718699,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432035136472017752790,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);

        (left, center, right, remainingEntropy) = degenGambit.outcome(
            52408262432035136472068786881,
            true
        );
        assertEq(left, 5);
        assertEq(center, 0);
        assertEq(right, 12);
        assertEq(remainingEntropy, 42);
    }
}
