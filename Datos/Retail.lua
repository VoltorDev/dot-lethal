-- Generado por tools/generar_datos.py con las tablas del cliente (wago.tools, build 12.1.5.70448, 21-10-2026). No editar a mano.
local _, ns = ...
ns.DATOS = ns.DATOS or {}
-- [spellID que se lanza] = { aura, periodo (s), prisa, duración base (s), familia, máscara de clase }
ns.DATOS.Retail = {
    dots = {
        [133] = { aura = 49512, periodo = 2, prisa = false, duracion = 4, familia = 3, mascara = { 0, 0, 0, 0 } }, -- Fireball
        [172] = { aura = 146739, periodo = 2, prisa = true, duracion = 14, familia = 5, mascara = { 2, 131072, 0, 0 } }, -- Corruption
        [339] = { aura = 339, periodo = 2, prisa = true, duracion = 30, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [348] = {
            aura = 157736,
            periodo = 3,
            prisa = true,
            duracion = 18,
            familia = 5,
            mascara = { 16, 131072, 0, 4194304 },
        }, -- Immolate
        [589] = { aura = 589, periodo = 2, prisa = true, duracion = 16, familia = 6, mascara = { 32768, 0, 256, 0 } }, -- Shadow Word: Pain
        [603] = {
            aura = 344324,
            periodo = 20,
            prisa = true,
            duracion = 20,
            familia = 5,
            mascara = { 0, 131074, 0, 67108864 },
        }, -- Doom
        [703] = { aura = 703, periodo = 2, prisa = true, duracion = 18, familia = 8, mascara = { 256, 4194304, 0, 0 } }, -- Garrote
        [772] = { aura = 394063, periodo = 3, prisa = true, duracion = 15, familia = 4, mascara = { 544, 0, 0, 16 } }, -- Rend
        [980] = { aura = 980, periodo = 2, prisa = true, duracion = 18, familia = 5, mascara = { 1024, 131072, 0, 0 } }, -- Agony
        [1079] = { aura = 1079, periodo = 2, prisa = true, duracion = 4, familia = 7, mascara = { 0, 0, 2097152, 4 } }, -- Rip
        [1822] = { aura = 155722, periodo = 3, prisa = true, duracion = 15, familia = 7, mascara = { 4096, 0, 0, 4 } }, -- Rake
        [1943] = {
            aura = 1943,
            periodo = 2,
            prisa = true,
            duracion = 4,
            familia = 8,
            mascara = { 1048576, 4194304, 0, 0 },
        }, -- Rupture
        [2818] = {
            aura = 2818,
            periodo = 2,
            prisa = true,
            duracion = 12,
            familia = 8,
            mascara = { 65536, 4718592, 0, 0 },
        }, -- Deadly Poison
        [2823] = {
            aura = 2818,
            periodo = 2,
            prisa = true,
            duracion = 12,
            familia = 8,
            mascara = { 65536, 4718592, 0, 0 },
        }, -- Deadly Poison
        [8921] = {
            aura = 164812,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 7,
            mascara = { 262144, 0, 268435456, 0 },
        }, -- Moonfire
        [11366] = { aura = 321712, periodo = 2, prisa = true, duracion = 6, familia = 3, mascara = { 8, 0, 0, 0 } }, -- Pyroblast
        [14914] = {
            aura = 14914,
            periodo = 1,
            prisa = true,
            duracion = 7,
            familia = 6,
            mascara = { 1048576, 0, 256, 0 },
        }, -- Holy Fire
        [17962] = {
            aura = 290644,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 5,
            mascara = { 0, 131072, 8388608, 4194304 },
        }, -- Conflagrate
        [26573] = { aura = 451923, periodo = 2, prisa = false, duracion = 0, familia = 10, mascara = { 0, 0, 0, 0 } }, -- Consecration
        [27243] = {
            aura = 27243,
            periodo = 12,
            prisa = true,
            duracion = 12,
            familia = 5,
            mascara = { 0, 131088, 0, 0 },
        }, -- Seed of Corruption
        [29722] = { aura = 40239, periodo = 1, prisa = false, duracion = 3, familia = 5, mascara = { 0, 0, 0, 0 } }, -- Incinerate
        [33917] = { aura = 241644, periodo = 3, prisa = false, duracion = 15, familia = 7, mascara = { 0, 0, 0, 0 } }, -- Mangle
        [34914] = { aura = 34914, periodo = 3, prisa = true, duracion = 21, familia = 6, mascara = { 0, 1024, 256, 0 } }, -- Vampiric Touch
        [44457] = { aura = 438672, periodo = 1, prisa = true, duracion = 2, familia = 3, mascara = { 8, 131072, 8, 0 } }, -- Living Bomb
        [47481] = { aura = 260563, periodo = 2, prisa = false, duracion = 6, familia = 15, mascara = { 0, 0, 0, 0 } }, -- Gnaw
        [55078] = {
            aura = 55078,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 15,
            mascara = { 0, 33556480, 0, 0 },
        }, -- Blood Plague
        [55095] = {
            aura = 55095,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 15,
            mascara = { 0, 67110912, 0, 16777216 },
        }, -- Frost Fever
        [63106] = {
            aura = 63106,
            periodo = 3,
            prisa = true,
            duracion = 15,
            familia = 5,
            mascara = { 256, 131072, 0, 0 },
        }, -- Siphon Life
        [77575] = {
            aura = 1240996,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 15,
            mascara = { 0, 2048, 24578, 8388608 },
        }, -- Outbreak
        [77758] = {
            aura = 405233,
            periodo = 3,
            prisa = true,
            duracion = 15,
            familia = 7,
            mascara = { 0, 0, 4194304, 1073741828 },
        }, -- Thrash
        [81297] = { aura = 451923, periodo = 2, prisa = false, duracion = 0, familia = 10, mascara = { 0, 0, 0, 0 } }, -- Consecration
        [91800] = { aura = 260563, periodo = 2, prisa = false, duracion = 6, familia = 15, mascara = { 0, 0, 0, 0 } }, -- Gnaw
        [93402] = {
            aura = 164815,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 7,
            mascara = { 262144, 0, 0, -2147483648 },
        }, -- Sunfire
        [102359] = { aura = 102359, periodo = 2, prisa = false, duracion = 10, familia = 7, mascara = { 0, 0, 4, 0 } }, -- Mass Entanglement
        [106830] = {
            aura = 405233,
            periodo = 3,
            prisa = true,
            duracion = 15,
            familia = 7,
            mascara = { 0, 0, 4194304, 1073741828 },
        }, -- Thrash
        [113344] = {
            aura = 113344,
            periodo = 3,
            prisa = false,
            duracion = 6,
            familia = 4,
            mascara = { 512, 0, 0, 16777216 },
        }, -- Bloodbath
        [113780] = { aura = 145420, periodo = 3, prisa = false, duracion = 12, familia = 8, mascara = { 0, 0, 0, 0 } }, -- Deadly Poison
        [114923] = {
            aura = 114923,
            periodo = 1,
            prisa = true,
            duracion = 12,
            familia = 3,
            mascara = { 8, 0, 33554440, 0 },
        }, -- Nether Tempest
        [115181] = {
            aura = 123725,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 53,
            mascara = { 0, 0, 0, 536870912 },
        }, -- Breath of Fire
        [115989] = {
            aura = 115994,
            periodo = 2,
            prisa = false,
            duracion = 14,
            familia = 15,
            mascara = { 0, 2048, 536887296, 0 },
        }, -- Unholy Blight
        [116858] = { aura = 196670, periodo = 1, prisa = false, duracion = 0, familia = 5, mascara = { 0, 0, 0, 0 } }, -- Chaos Bolt
        [118297] = { aura = 118297, periodo = 3, prisa = true, duracion = 21, familia = 11, mascara = { 0, 0, 0, 128 } }, -- Immolate
        [122470] = {
            aura = 124280,
            periodo = 1,
            prisa = false,
            duracion = 6,
            familia = 53,
            mascara = { 2048, 0, 0, 0 },
        }, -- Touch of Karma
        [124280] = {
            aura = 124280,
            periodo = 1,
            prisa = false,
            duracion = 6,
            familia = 53,
            mascara = { 2048, 0, 0, 0 },
        }, -- Touch of Karma
        [146739] = {
            aura = 146739,
            periodo = 2,
            prisa = true,
            duracion = 14,
            familia = 5,
            mascara = { 2, 131072, 0, 0 },
        }, -- Corruption
        [152108] = { aura = 242943, periodo = 1, prisa = false, duracion = 5, familia = 5, mascara = { 0, 0, 0, 0 } }, -- Cataclysm
        [162487] = {
            aura = 162487,
            periodo = 2,
            prisa = true,
            duracion = 20,
            familia = 9,
            mascara = { 0, 16, 0, 1024 },
        }, -- Steel Trap
        [162488] = {
            aura = 162487,
            periodo = 2,
            prisa = true,
            duracion = 20,
            familia = 9,
            mascara = { 0, 16, 0, 1024 },
        }, -- Steel Trap
        [164812] = {
            aura = 164812,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 7,
            mascara = { 262144, 0, 268435456, 0 },
        }, -- Moonfire
        [164815] = {
            aura = 164815,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 7,
            mascara = { 262144, 0, 0, -2147483648 },
        }, -- Sunfire
        [191034] = { aura = 274858, periodo = 1, prisa = false, duracion = 10, familia = 7, mascara = { 0, 0, 0, 0 } }, -- Starfall
        [195292] = {
            aura = 55078,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 15,
            mascara = { 0, 33556480, 0, 0 },
        }, -- Death's Caress
        [202347] = {
            aura = 202347,
            periodo = 2,
            prisa = true,
            duracion = 24,
            familia = 7,
            mascara = { 262144, 0, 0, 512 },
        }, -- Stellar Flare
        [204021] = {
            aura = 207771,
            periodo = 1,
            prisa = false,
            duracion = 12,
            familia = 107,
            mascara = { 0, 16, 320, 0 },
        }, -- Fiery Brand
        [204066] = {
            aura = 1270292,
            periodo = 1,
            prisa = false,
            duracion = 8,
            familia = 7,
            mascara = { 0, 0, 8192, 8192 },
        }, -- Lunar Beam
        [204596] = {
            aura = 204598,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 107,
            mascara = { 65536, 2, 322, 0 },
        }, -- Sigil of Flame
        [205179] = {
            aura = 205179,
            periodo = 2,
            prisa = true,
            duracion = 16,
            familia = 5,
            mascara = { 0, 131072, 1048576, 0 },
        }, -- Phantom Singularity
        [205273] = { aura = 205273, periodo = 1, prisa = false, duracion = 6, familia = 10, mascara = { 0, 0, 0, 0 } }, -- Wake of Ashes
        [205545] = { aura = 205546, periodo = 1, prisa = false, duracion = 4, familia = 4, mascara = { 0, 0, 0, 0 } }, -- Odyn's Fury
        [205546] = { aura = 205546, periodo = 1, prisa = false, duracion = 4, familia = 4, mascara = { 0, 0, 0, 0 } }, -- Odyn's Fury
        [205547] = {
            aura = 385060,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 4,
            mascara = { 512, 0, 0, 16777472 },
        }, -- Odyn's Fury
        [207407] = {
            aura = 207407,
            periodo = 1,
            prisa = false,
            duracion = 3,
            familia = 107,
            mascara = { 0, 16385, 320, 0 },
        }, -- Soul Carver
        [210722] = { aura = 210723, periodo = 2, prisa = false, duracion = 6, familia = 7, mascara = { 0, 0, 0, 0 } }, -- Ashamane's Frenzy
        [210723] = { aura = 210723, periodo = 2, prisa = false, duracion = 6, familia = 7, mascara = { 0, 0, 0, 0 } }, -- Ashamane's Frenzy
        [212431] = {
            aura = 212431,
            periodo = 1,
            prisa = false,
            duracion = 3,
            familia = 9,
            mascara = { 2, -2147483648, 0, 33555456 },
        }, -- Explosive Shot
        [214743] = {
            aura = 207407,
            periodo = 1,
            prisa = false,
            duracion = 3,
            familia = 107,
            mascara = { 0, 16385, 320, 0 },
        }, -- Soul Carver
        [215279] = { aura = 196670, periodo = 1, prisa = false, duracion = 0, familia = 5, mascara = { 0, 0, 0, 0 } }, -- Chaos Bolt
        [215537] = { aura = 215537, periodo = 2, prisa = false, duracion = 6, familia = 4, mascara = { 0, 0, 0, 0 } }, -- Trauma
        [217200] = {
            aura = 217200,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 2, 0, 16384, 1024 },
        }, -- Barbed Shot
        [255937] = {
            aura = 403695,
            periodo = 3,
            prisa = true,
            duracion = 9,
            familia = 10,
            mascara = { 134217728, 0, 18, 0 },
        }, -- Wake of Ashes
        [259495] = {
            aura = 1253171,
            periodo = 1,
            prisa = false,
            duracion = 6,
            familia = 9,
            mascara = { 4194304, 0, 0, 67109888 },
        }, -- Wildfire Bomb
        [271788] = {
            aura = 271788,
            periodo = 3,
            prisa = true,
            duracion = 18,
            familia = 9,
            mascara = { 16386, 8388608, 0, 33555456 },
        }, -- Serpent Sting
        [274837] = {
            aura = 274838,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 7,
            mascara = { 0, 0, 1073741824, 4 },
        }, -- Feral Frenzy
        [278350] = {
            aura = 386931,
            periodo = 2,
            prisa = true,
            duracion = 10,
            familia = 5,
            mascara = { 0, 131072, 2097152, 0 },
        }, -- Vile Taint
        [307443] = { aura = 307443, periodo = 2, prisa = true, duracion = 10, familia = 3, mascara = { 8, 0, 2048, 0 } }, -- Radiant Spark
        [307865] = {
            aura = 307871,
            periodo = 1,
            prisa = true,
            duracion = 4,
            familia = 4,
            mascara = { 512, 33554432, 0, 0 },
        }, -- Spear of Bastion
        [312202] = {
            aura = 312202,
            periodo = 2,
            prisa = true,
            duracion = 14,
            familia = 15,
            mascara = { 0, 2048, 0, -2147483648 },
        }, -- Shackle the Unworthy
        [312321] = {
            aura = 312321,
            periodo = 3,
            prisa = true,
            duracion = 18,
            familia = 5,
            mascara = { 0, 131072, 0, 0 },
        }, -- Scouring Tithe
        [317009] = {
            aura = 317009,
            periodo = 2,
            prisa = true,
            duracion = 8,
            familia = 107,
            mascara = { 65536, 1, 524352, 0 },
        }, -- Sinful Brand
        [321530] = {
            aura = 321538,
            periodo = 1,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 6, 33554432, 0, 1024 },
        }, -- Bloodshed
        [321792] = {
            aura = 322170,
            periodo = 2,
            prisa = true,
            duracion = 12,
            familia = 5,
            mascara = { 0, 131072, 0, 0 },
        }, -- Impending Catastrophe
        [323639] = {
            aura = 345335,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 107,
            mascara = { 65536, 0, 8388672, 0 },
        }, -- The Hunt
        [324149] = {
            aura = 324149,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 9,
            mascara = { 2, 8388608, 1024, 33555456 },
        }, -- Flayed Shot
        [324724] = {
            aura = 325203,
            periodo = 3,
            prisa = true,
            duracion = 15,
            familia = 6,
            mascara = { 0, 0, 256, 262144 },
        }, -- Unholy Nova
        [325640] = {
            aura = 325640,
            periodo = 2,
            prisa = true,
            duracion = 8,
            familia = 5,
            mascara = { 0, 131072, 0, 65536 },
        }, -- Soul Rot
        [325727] = {
            aura = 391889,
            periodo = 2,
            prisa = true,
            duracion = 12,
            familia = 7,
            mascara = { 4194304, 0, 0, 4 },
        }, -- Adaptive Swarm
        [328305] = {
            aura = 328305,
            periodo = 1,
            prisa = true,
            duracion = 10,
            familia = 8,
            mascara = { 0, 4194304, 0, 4194304 },
        }, -- Sepsis
        [328547] = {
            aura = 324073,
            periodo = 3,
            prisa = false,
            duracion = 0,
            familia = 8,
            mascara = { 0, 4194304, 0, 524288 },
        }, -- Serrated Bone Spike
        [335467] = {
            aura = 335467,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 6,
            mascara = { 0, 0, 8388864, 0 },
        }, -- Shadow Word: Madness
        [357170] = { aura = 361029, periodo = 1, prisa = false, duracion = 0, familia = 224, mascara = { 0, 0, 0, 0 } }, -- Time Dilation
        [357210] = { aura = 353759, periodo = 0.5, prisa = true, duracion = 1, familia = 224, mascara = { 1, 4, 0, 0 } }, -- Deep Breath
        [360194] = {
            aura = 360194,
            periodo = 2,
            prisa = true,
            duracion = 16,
            familia = 8,
            mascara = { 0, 138412032, 0, 0 },
        }, -- Deathmark
        [360966] = { aura = 389881, periodo = 2, prisa = false, duracion = 4, familia = 9, mascara = { 0, 0, 0, 0 } }, -- Spearhead
        [361469] = {
            aura = 361500,
            periodo = 3,
            prisa = true,
            duracion = 12,
            familia = 224,
            mascara = { 129, 262144, 0, 0 },
        }, -- Living Flame
        [368847] = { aura = 456657, periodo = 2, prisa = true, duracion = 12, familia = 224, mascara = { 1, 0, 1, 0 } }, -- Firestorm
        [370965] = {
            aura = 1246168,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 107,
            mascara = { 0, 2048, -2139095040, 0 },
        }, -- The Hunt
        [376079] = {
            aura = 376080,
            periodo = 1,
            prisa = true,
            duracion = 6,
            familia = 4,
            mascara = { 512, 33554432, 0, 0 },
        }, -- Champion's Spear
        [376103] = { aura = 376103, periodo = 2, prisa = true, duracion = 12, familia = 3, mascara = { 8, 0, 2048, 0 } }, -- Radiant Spark
        [384069] = {
            aura = 205181,
            periodo = 2,
            prisa = true,
            duracion = 8,
            familia = 5,
            mascara = { 0, 131584, 0, 0 },
        }, -- Shadowflame
        [384318] = {
            aura = 397364,
            periodo = 2,
            prisa = true,
            duracion = 8,
            familia = 4,
            mascara = { 512, 0, 134217728, 16777216 },
        }, -- Thunderous Roar
        [385059] = {
            aura = 385060,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 4,
            mascara = { 512, 0, 0, 16777472 },
        }, -- Odyn's Fury
        [385408] = {
            aura = 385408,
            periodo = 1,
            prisa = true,
            duracion = 10,
            familia = 8,
            mascara = { 0, 4194304, 0, 4194304 },
        }, -- Sepsis
        [385424] = {
            aura = 394036,
            periodo = 3,
            prisa = false,
            duracion = 0,
            familia = 8,
            mascara = { 0, 4194304, 0, 524288 },
        }, -- Serrated Bone Spike
        [385627] = {
            aura = 385627,
            periodo = 2,
            prisa = false,
            duracion = 14,
            familia = 8,
            mascara = { 0, 4194304, 2097152, 8388608 },
        }, -- Kingsbane
        [386997] = {
            aura = 386997,
            periodo = 2,
            prisa = true,
            duracion = 8,
            familia = 5,
            mascara = { 0, 131072, 0, 65536 },
        }, -- Soul Rot
        [394062] = {
            aura = 388539,
            periodo = 3,
            prisa = true,
            duracion = 15,
            familia = 4,
            mascara = { 544, 0, 0, 16777216 },
        }, -- Rend
        [426591] = {
            aura = 426593,
            periodo = 2,
            prisa = true,
            duracion = 14,
            familia = 8,
            mascara = { 0, 4194304, 8, 0 },
        }, -- Goremaw's Bite
        [431044] = { aura = 468655, periodo = 1, prisa = true, duracion = 8, familia = 3, mascara = { 41, 0, 0, 4096 } }, -- Frostfire Bolt
        [445468] = {
            aura = 445474,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 5,
            mascara = { 18, 131072, 0, 4194304 },
        }, -- Wither
        [466930] = {
            aura = 468572,
            periodo = 1,
            prisa = false,
            duracion = 8,
            familia = 9,
            mascara = { 0, 0, 134217728, 0 },
        }, -- Black Arrow
        [470411] = {
            aura = 188389,
            periodo = 2,
            prisa = true,
            duracion = 18,
            familia = 11,
            mascara = { 268435456, 16777344, 0, 1073741952 },
        }, -- Flame Shock
        [1219074] = {
            aura = 1219210,
            periodo = 1,
            prisa = false,
            duracion = 8,
            familia = 107,
            mascara = { 0, 1, -2145386496, 0 },
        }, -- Abyssal Breach
        [1243807] = {
            aura = 1244079,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 7,
            mascara = { 0, 0, 1073741824, 4 },
        }, -- Frantic Frenzy
        [1246167] = {
            aura = 1246168,
            periodo = 2,
            prisa = true,
            duracion = 6,
            familia = 107,
            mascara = { 0, 2048, -2139095040, 0 },
        }, -- The Hunt
        [1252871] = {
            aura = 1252871,
            periodo = 1,
            prisa = false,
            duracion = 8,
            familia = 7,
            mascara = { 0, 0, 268435456, 0 },
        }, -- Red Moon
        [1259790] = {
            aura = 1259790,
            periodo = 2,
            prisa = true,
            duracion = 8,
            familia = 5,
            mascara = { 0, 131328, 0, 0 },
        }, -- Unstable Affliction
    },
    -- Talentos pasivos que cambian el ritmo de ticks (operación 19, Period): pct sobre el periodo.
    ritmos = {
        { talento = 193134, pct = -34, familia = 6, mascara = { 0, 0, 128, 0 } }, -- Castigation
        { talento = 194662, pct = -15, familia = 15, mascara = { 32, 33554432, 0, 0 } }, -- Rapid Decomposition
        { talento = 207269, pct = -25, familia = 15, mascara = { 0, 256, 8192, 0 } }, -- Ebon Fever
        { talento = 236628, pct = -30, familia = 3, mascara = { 2048, 0, 0, 0 } }, -- Amplification
        { talento = 264000, pct = -10, familia = 5, mascara = { 1282, 256, 0, 0 } }, -- Creeping Death
        { talento = 338657, pct = -25, familia = 7, mascara = { 262144, 0, 8192, 268435460 } }, -- Circle of Life and Death
        { talento = 338657, pct = -15, familia = 7, mascara = { 0, 0, 0, 4194304 } }, -- Circle of Life and Death
        { talento = 369913, pct = -20, familia = 224, mascara = { 64, 0, 0, 0 } }, -- Natural Convergence
        { talento = 372945, pct = 33, familia = 7, mascara = { 0, 1073741824, 0, 0 } }, -- Reinvigoration
        { talento = 378266, pct = -13, familia = 11, mascara = { 268435456, 0, 0, 0 } }, -- Flames of the Cauldron
        { talento = 387166, pct = -12, familia = 5, mascara = { 32, 0, 0, 0 } }, -- Raging Demonfire
        { talento = 400059, pct = -20, familia = 7, mascara = { 0, 0, 268435456, -1879048192 } }, -- Cosmic Rapidity
        { talento = 400320, pct = -20, familia = 7, mascara = { 262144, 256, 134283264, 268435460 } }, -- Circle of Life and Death
        { talento = 400320, pct = -15, familia = 7, mascara = { 0, 0, 0, 4194304 } }, -- Circle of Life and Death
        { talento = 414379, pct = -20, familia = 3, mascara = { 2048, 0, 0, 0 } }, -- Concentrated Power
        { talento = 422031, pct = -50, familia = 53, mascara = { 0, 0, 1, 0 } }, -- Energizing Brew
        { talento = 426702, pct = -25, familia = 7, mascara = { 262144, 0, 65536, 268435460 } }, -- Liveliness
        { talento = 426702, pct = -5, familia = 7, mascara = { 0, 0, 0, 4194304 } }, -- Liveliness
        { talento = 441894, pct = -50, familia = 15, mascara = { 0, 33554432, 0, 0 } }, -- Wither Away
        { talento = 441894, pct = -43, familia = 15, mascara = { 0, 67108864, 0, 0 } }, -- Wither Away
        { talento = 449637, pct = -25, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Sataiel's Volition
        { talento = 459794, pct = -34, familia = 9, mascara = { 0, 0, 0, 4194304 } }, -- Quick Draw
        { talento = 459809, pct = -50, familia = 53, mascara = { 0, 1, 0, 0 } }, -- Power of the Thunder King
        { talento = 469012, pct = -15, familia = 7, mascara = { 0, 0, 268435456, -1870659072 } }, -- Circle of Life and Death
        { talento = 469012, pct = -15, familia = 7, mascara = { 0, 0, 0, 4194304 } }, -- Circle of Life and Death
        { talento = 1218447, pct = -15, familia = 224, mascara = { 2097152, 8, 0, 0 } }, -- Fulminous Roar
        { talento = 1219723, pct = -25, familia = 224, mascara = { 64, 0, 0, 0 } }, -- Azure Celerity
        { talento = 1234559, pct = -50, familia = 15, mascara = { 32, 0, 0, 0 } }, -- Desecrate
        { talento = 1240262, pct = -50, familia = 7, mascara = { 0, 0, 0, 8388608 } }, -- Meteor Storm
        { talento = 1244928, pct = -25, familia = 5, mascara = { 0, 0, 0, 268435456 } }, -- Destructive Rapidity
        { talento = 1244928, pct = -10, familia = 5, mascara = { 131072, 0, 0, 0 } }, -- Destructive Rapidity
        { talento = 1253099, pct = -13, familia = 11, mascara = { 8192, 0, 0, 0 } }, -- Quickstream
        { talento = 1262334, pct = -75, familia = 53, mascara = { 0, 1, 0, 0 } }, -- Jade Flash
        { talento = 1266845, pct = -20, familia = 6, mascara = { 32768, 4096, 0, 0 } }, -- Quickened Pulse
        { talento = 1270701, pct = -50, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Gorefiend's Avarice
    },
}
