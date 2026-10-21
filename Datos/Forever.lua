-- Generado por tools/generar_datos.py con las tablas del cliente (wago.tools, build 1.60.1.70245, 21-10-2026). No editar a mano.
local _, ns = ...
ns.DATOS = ns.DATOS or {}
-- [spellID que se lanza] = { aura, periodo (s), prisa, duración base (s), familia, máscara de clase }
ns.DATOS.Forever = {
    dots = {
        [133] = { aura = 133, periodo = 2, prisa = false, duracion = 4, familia = 3, mascara = { 1073741825, 0, 0, 0 } }, -- Fireball
        [143] = { aura = 143, periodo = 2, prisa = false, duracion = 6, familia = 3, mascara = { 1073741825, 0, 0, 0 } }, -- Fireball
        [145] = { aura = 145, periodo = 2, prisa = false, duracion = 6, familia = 3, mascara = { 1073741825, 0, 0, 0 } }, -- Fireball
        [172] = { aura = 172, periodo = 3, prisa = false, duracion = 12, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [339] = { aura = 339, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [348] = { aura = 348, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [589] = { aura = 589, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [594] = { aura = 594, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [603] = {
            aura = 603,
            periodo = 60,
            prisa = false,
            duracion = 60,
            familia = 5,
            mascara = { -2147483648, 2, 0, 0 },
        }, -- Bane of Doom
        [703] = { aura = 703, periodo = 3, prisa = false, duracion = 18, familia = 8, mascara = { 256, 0, 0, 0 } }, -- Garrote
        [707] = { aura = 707, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [772] = { aura = 772, periodo = 3, prisa = false, duracion = 9, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [970] = { aura = 970, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [980] = { aura = 980, periodo = 2, prisa = false, duracion = 24, familia = 5, mascara = { 1024, 0, 0, 0 } }, -- Bane of Agony
        [992] = { aura = 992, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [1014] = { aura = 1014, periodo = 2, prisa = false, duracion = 24, familia = 5, mascara = { 1024, 0, 0, 0 } }, -- Bane of Agony
        [1062] = { aura = 1062, periodo = 3, prisa = false, duracion = 15, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [1079] = {
            aura = 1079,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 8388608, 0, 2097152, 0 },
        }, -- Rip
        [1094] = { aura = 1094, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [1822] = {
            aura = 1822,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 7,
            mascara = { 4096, 0, 0, 1073741824 },
        }, -- Rake
        [1823] = {
            aura = 1823,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 7,
            mascara = { 4096, 0, 0, 1073741824 },
        }, -- Rake
        [1824] = {
            aura = 1824,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 7,
            mascara = { 4096, 0, 0, 1073741824 },
        }, -- Rake
        [1943] = { aura = 1943, periodo = 2, prisa = false, duracion = 6, familia = 8, mascara = { 1048576, 0, 0, 0 } }, -- Rupture
        [1978] = { aura = 1978, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [2767] = { aura = 2767, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [2941] = { aura = 2941, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [2944] = {
            aura = 2944,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 6,
            mascara = { 33554432, 0, 0, 16 },
        }, -- Devouring Plague
        [3140] = {
            aura = 3140,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [3674] = { aura = 3674, periodo = 2, prisa = false, duracion = 30, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Black Arrow
        [5195] = { aura = 5195, periodo = 3, prisa = false, duracion = 18, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [5196] = { aura = 5196, periodo = 3, prisa = false, duracion = 21, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [5570] = { aura = 5570, periodo = 2, prisa = false, duracion = 12, familia = 7, mascara = { 2097152, 0, 0, 0 } }, -- Insect Swarm
        [6217] = { aura = 6217, periodo = 2, prisa = false, duracion = 24, familia = 5, mascara = { 1024, 0, 0, 0 } }, -- Bane of Agony
        [6222] = { aura = 6222, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [6223] = { aura = 6223, periodo = 3, prisa = false, duracion = 18, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [6546] = { aura = 6546, periodo = 3, prisa = false, duracion = 12, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [6547] = { aura = 6547, periodo = 3, prisa = false, duracion = 15, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [6548] = { aura = 6548, periodo = 3, prisa = false, duracion = 18, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [7648] = { aura = 7648, periodo = 3, prisa = false, duracion = 18, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [8050] = {
            aura = 8050,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 11,
            mascara = { 268435456, 0, 0, 0 },
        }, -- Flame Shock
        [8052] = {
            aura = 8052,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 11,
            mascara = { 268435456, 0, 0, 0 },
        }, -- Flame Shock
        [8053] = {
            aura = 8053,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 11,
            mascara = { 268435456, 0, 0, 0 },
        }, -- Flame Shock
        [8400] = {
            aura = 8400,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [8401] = {
            aura = 8401,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [8402] = {
            aura = 8402,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [8631] = { aura = 8631, periodo = 3, prisa = false, duracion = 18, familia = 8, mascara = { 256, 0, 0, 0 } }, -- Garrote
        [8632] = { aura = 8632, periodo = 3, prisa = false, duracion = 18, familia = 8, mascara = { 256, 0, 0, 0 } }, -- Garrote
        [8633] = { aura = 8633, periodo = 3, prisa = false, duracion = 18, familia = 8, mascara = { 256, 0, 0, 0 } }, -- Garrote
        [8639] = { aura = 8639, periodo = 2, prisa = false, duracion = 6, familia = 8, mascara = { 1048576, 0, 0, 0 } }, -- Rupture
        [8640] = { aura = 8640, periodo = 2, prisa = false, duracion = 6, familia = 8, mascara = { 1048576, 0, 0, 0 } }, -- Rupture
        [8921] = { aura = 8921, periodo = 3, prisa = false, duracion = 9, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [8924] = { aura = 8924, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [8925] = { aura = 8925, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [8926] = { aura = 8926, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [8927] = { aura = 8927, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [8928] = { aura = 8928, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [8929] = { aura = 8929, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [9005] = { aura = 9007, periodo = 3, prisa = false, duracion = 18, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Pounce
        [9007] = { aura = 9007, periodo = 3, prisa = false, duracion = 18, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Pounce Bleed
        [9492] = {
            aura = 9492,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 8388608, 0, 2097152, 0 },
        }, -- Rip
        [9493] = {
            aura = 9493,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 8388608, 0, 2097152, 0 },
        }, -- Rip
        [9752] = {
            aura = 9752,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 8388608, 0, 2097152, 0 },
        }, -- Rip
        [9823] = { aura = 9824, periodo = 3, prisa = false, duracion = 18, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Pounce
        [9824] = { aura = 9824, periodo = 3, prisa = false, duracion = 18, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Pounce Bleed
        [9826] = { aura = 9826, periodo = 3, prisa = false, duracion = 18, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Pounce Bleed
        [9827] = { aura = 9826, periodo = 3, prisa = false, duracion = 18, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Pounce
        [9833] = { aura = 9833, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [9834] = { aura = 9834, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [9835] = { aura = 9835, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 2, 0, 0, 0 } }, -- Moonfire
        [9852] = { aura = 9852, periodo = 3, prisa = false, duracion = 24, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [9853] = { aura = 9853, periodo = 3, prisa = false, duracion = 27, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Entangling Roots
        [9894] = {
            aura = 9894,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 8388608, 0, 2097152, 0 },
        }, -- Rip
        [9896] = {
            aura = 9896,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 8388608, 0, 2097152, 0 },
        }, -- Rip
        [9904] = {
            aura = 9904,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 7,
            mascara = { 4096, 0, 0, 1073741824 },
        }, -- Rake
        [10148] = {
            aura = 10148,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [10149] = {
            aura = 10149,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [10150] = {
            aura = 10150,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [10151] = {
            aura = 10151,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [10447] = {
            aura = 10447,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 11,
            mascara = { 268435456, 0, 0, 0 },
        }, -- Flame Shock
        [10448] = {
            aura = 10448,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 11,
            mascara = { 268435456, 0, 0, 0 },
        }, -- Flame Shock
        [10892] = { aura = 10892, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [10893] = { aura = 10893, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [10894] = { aura = 10894, periodo = 3, prisa = false, duracion = 18, familia = 6, mascara = { 32768, 0, 0, 0 } }, -- Shadow Word: Pain
        [11273] = {
            aura = 11273,
            periodo = 2,
            prisa = false,
            duracion = 6,
            familia = 8,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Rupture
        [11274] = {
            aura = 11274,
            periodo = 2,
            prisa = false,
            duracion = 6,
            familia = 8,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Rupture
        [11275] = {
            aura = 11275,
            periodo = 2,
            prisa = false,
            duracion = 6,
            familia = 8,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Rupture
        [11289] = { aura = 11289, periodo = 3, prisa = false, duracion = 18, familia = 8, mascara = { 256, 0, 0, 0 } }, -- Garrote
        [11290] = { aura = 11290, periodo = 3, prisa = false, duracion = 18, familia = 8, mascara = { 256, 0, 0, 0 } }, -- Garrote
        [11366] = {
            aura = 11366,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [11572] = { aura = 11572, periodo = 3, prisa = false, duracion = 21, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [11573] = { aura = 11573, periodo = 3, prisa = false, duracion = 21, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [11574] = { aura = 11574, periodo = 3, prisa = false, duracion = 21, familia = 4, mascara = { 32, 0, 0, 0 } }, -- Rend
        [11665] = { aura = 11665, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [11667] = { aura = 11667, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [11668] = { aura = 11668, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [11671] = { aura = 11671, periodo = 3, prisa = false, duracion = 18, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [11672] = { aura = 11672, periodo = 3, prisa = false, duracion = 18, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [11711] = { aura = 11711, periodo = 2, prisa = false, duracion = 24, familia = 5, mascara = { 1024, 0, 0, 0 } }, -- Bane of Agony
        [11712] = { aura = 11712, periodo = 2, prisa = false, duracion = 24, familia = 5, mascara = { 1024, 0, 0, 0 } }, -- Bane of Agony
        [11713] = { aura = 11713, periodo = 2, prisa = false, duracion = 24, familia = 5, mascara = { 1024, 0, 0, 0 } }, -- Bane of Agony
        [12505] = {
            aura = 12505,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [12522] = {
            aura = 12522,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [12523] = {
            aura = 12523,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [12524] = {
            aura = 12524,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [12525] = {
            aura = 12525,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [12526] = {
            aura = 12526,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [13549] = { aura = 13549, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13550] = { aura = 13550, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13551] = { aura = 13551, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13552] = { aura = 13552, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13553] = { aura = 13553, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13554] = { aura = 13554, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13555] = { aura = 13555, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [13797] = {
            aura = 13797,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 9,
            mascara = { 4, 0, 131072, 0 },
        }, -- Immolation Trap Effect
        [13812] = { aura = 13812, periodo = 2, prisa = false, duracion = 20, familia = 9, mascara = { 4, 0, 16384, 0 } }, -- Explosive Trap Effect
        [14296] = { aura = 14296, periodo = 2, prisa = false, duracion = 30, familia = 0, mascara = { 0, 0, 0, 0 } }, -- Black Arrow
        [14298] = {
            aura = 14298,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 9,
            mascara = { 4, 0, 131072, 0 },
        }, -- Immolation Trap Effect
        [14299] = {
            aura = 14299,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 9,
            mascara = { 4, 0, 131072, 0 },
        }, -- Immolation Trap Effect
        [14300] = {
            aura = 14300,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 9,
            mascara = { 4, 0, 131072, 0 },
        }, -- Immolation Trap Effect
        [14301] = {
            aura = 14301,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 9,
            mascara = { 4, 0, 131072, 0 },
        }, -- Immolation Trap Effect
        [14314] = { aura = 14314, periodo = 2, prisa = false, duracion = 20, familia = 9, mascara = { 4, 0, 16384, 0 } }, -- Explosive Trap Effect
        [14315] = { aura = 14315, periodo = 2, prisa = false, duracion = 20, familia = 9, mascara = { 4, 0, 16384, 0 } }, -- Explosive Trap Effect
        [14914] = {
            aura = 14914,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15261] = {
            aura = 15261,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15262] = {
            aura = 15262,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15263] = {
            aura = 15263,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15264] = {
            aura = 15264,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15265] = {
            aura = 15265,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15266] = {
            aura = 15266,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [15267] = {
            aura = 15267,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 6,
            mascara = { 1048576, 0, 0, 0 },
        }, -- Holy Fire
        [16689] = { aura = 19975, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Nature's Grasp
        [16810] = { aura = 19974, periodo = 3, prisa = false, duracion = 15, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Nature's Grasp
        [16811] = { aura = 19973, periodo = 3, prisa = false, duracion = 18, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Nature's Grasp
        [16812] = { aura = 19972, periodo = 3, prisa = false, duracion = 21, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Nature's Grasp
        [16813] = { aura = 19971, periodo = 3, prisa = false, duracion = 24, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Nature's Grasp
        [17329] = { aura = 19970, periodo = 3, prisa = false, duracion = 27, familia = 7, mascara = { 512, 0, 0, 0 } }, -- Nature's Grasp
        [18265] = { aura = 18265, periodo = 3, prisa = false, duracion = 30, familia = 5, mascara = { 0, 1, 0, 0 } }, -- Siphon Life
        [18809] = {
            aura = 18809,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 1077936128, 0, 0, 0 },
        }, -- Pyroblast
        [18879] = { aura = 18879, periodo = 3, prisa = false, duracion = 30, familia = 5, mascara = { 0, 1, 0, 0 } }, -- Siphon Life
        [18880] = { aura = 18880, periodo = 3, prisa = false, duracion = 30, familia = 5, mascara = { 0, 1, 0, 0 } }, -- Siphon Life
        [18881] = { aura = 18881, periodo = 3, prisa = false, duracion = 30, familia = 5, mascara = { 0, 1, 0, 0 } }, -- Siphon Life
        [19276] = {
            aura = 19276,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 6,
            mascara = { 33554432, 0, 0, 16 },
        }, -- Devouring Plague
        [19277] = {
            aura = 19277,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 6,
            mascara = { 33554432, 0, 0, 16 },
        }, -- Devouring Plague
        [19278] = {
            aura = 19278,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 6,
            mascara = { 33554432, 0, 0, 16 },
        }, -- Devouring Plague
        [19279] = {
            aura = 19279,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 6,
            mascara = { 33554432, 0, 0, 16 },
        }, -- Devouring Plague
        [19280] = {
            aura = 19280,
            periodo = 3,
            prisa = false,
            duracion = 24,
            familia = 6,
            mascara = { 33554432, 0, 0, 16 },
        }, -- Devouring Plague
        [24118] = { aura = 24118, periodo = 3, prisa = false, duracion = 21, familia = 9, mascara = { 0, 4096, 0, 0 } }, -- Lacerate
        [24119] = { aura = 24119, periodo = 3, prisa = false, duracion = 21, familia = 9, mascara = { 0, 4096, 0, 0 } }, -- Lacerate
        [24120] = { aura = 24120, periodo = 3, prisa = false, duracion = 21, familia = 9, mascara = { 0, 4096, 0, 0 } }, -- Lacerate
        [24583] = {
            aura = 24583,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24584] = {
            aura = 24583,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24586] = {
            aura = 24586,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24587] = {
            aura = 24587,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24588] = {
            aura = 24586,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24589] = {
            aura = 24587,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24640] = {
            aura = 24640,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24641] = {
            aura = 24640,
            periodo = 2,
            prisa = false,
            duracion = 10,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Scorpid Poison
        [24974] = {
            aura = 24974,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 2097152, 0, 0, 0 },
        }, -- Insect Swarm
        [24975] = {
            aura = 24975,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 2097152, 0, 0, 0 },
        }, -- Insect Swarm
        [24976] = {
            aura = 24976,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 2097152, 0, 0, 0 },
        }, -- Insect Swarm
        [24977] = {
            aura = 24977,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 7,
            mascara = { 2097152, 0, 0, 0 },
        }, -- Insect Swarm
        [25295] = { aura = 25295, periodo = 3, prisa = false, duracion = 15, familia = 9, mascara = { 16384, 0, 0, 0 } }, -- Serpent Sting
        [25306] = {
            aura = 25306,
            periodo = 2,
            prisa = false,
            duracion = 8,
            familia = 3,
            mascara = { 1073741825, 0, 0, 0 },
        }, -- Fireball
        [25309] = { aura = 25309, periodo = 3, prisa = false, duracion = 15, familia = 5, mascara = { 4, 0, 0, 0 } }, -- Immolate
        [25311] = { aura = 25311, periodo = 3, prisa = false, duracion = 18, familia = 5, mascara = { 2, 0, 0, 0 } }, -- Corruption
        [29228] = {
            aura = 29228,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 11,
            mascara = { 268435456, 0, 0, 0 },
        }, -- Flame Shock
        [400613] = {
            aura = 400613,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 0, 131072, 0, 0 },
        }, -- Living Bomb
        [400614] = {
            aura = 400613,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 3,
            mascara = { 0, 131072, 0, 0 },
        }, -- Living Bomb
        [401502] = {
            aura = 401502,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 3,
            mascara = { 1074790400, 4096, 8, 0 },
        }, -- Frostfire Bolt
        [401556] = {
            aura = 401558,
            periodo = 1,
            prisa = false,
            duracion = 2,
            familia = 3,
            mascara = { 0, 0, 262144, 0 },
        }, -- Living Flame
        [401558] = {
            aura = 401558,
            periodo = 1,
            prisa = false,
            duracion = 2,
            familia = 3,
            mascara = { 0, 0, 262144, 0 },
        }, -- Living Flame
        [402668] = {
            aura = 402668,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 6,
            mascara = { 0, 1024, 0, 0 },
        }, -- Vampiric Touch
        [403677] = { aura = 403677, periodo = 1, prisa = false, duracion = 15, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Drain Life
        [403685] = { aura = 403685, periodo = 1, prisa = false, duracion = 15, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Drain Life
        [403686] = { aura = 403686, periodo = 1, prisa = false, duracion = 15, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Drain Life
        [403687] = { aura = 403687, periodo = 1, prisa = false, duracion = 15, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Drain Life
        [403688] = { aura = 403688, periodo = 1, prisa = false, duracion = 15, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Drain Life
        [403689] = { aura = 403689, periodo = 1, prisa = false, duracion = 15, familia = 5, mascara = { 8, 0, 0, 0 } }, -- Drain Life
        [414644] = { aura = 414644, periodo = 3, prisa = false, duracion = 15, familia = 7, mascara = { 0, 256, 0, 0 } }, -- Lacerate
        [414647] = {
            aura = 1235827,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 7,
            mascara = { 0, 256, 0, 0 },
        }, -- Lacerate
        [414684] = { aura = 414684, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 0, 0, 0, 64 } }, -- Sunfire
        [414687] = { aura = 414687, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 0, 0, 0, 64 } }, -- Sunfire
        [414689] = { aura = 414689, periodo = 3, prisa = false, duracion = 12, familia = 7, mascara = { 0, 0, 0, 64 } }, -- Sunfire
        [424785] = {
            aura = 424785,
            periodo = 2,
            prisa = false,
            duracion = 12,
            familia = 8,
            mascara = { 8388608, 0, 0, 4 },
        }, -- Saber Slash
        [425204] = {
            aura = 425204,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 6,
            mascara = { 0, 0, 0, 268435456 },
        }, -- Void Plague
        [425728] = {
            aura = 425728,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425729] = {
            aura = 425729,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425730] = {
            aura = 425730,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425732] = {
            aura = 425732,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425733] = {
            aura = 425733,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425734] = {
            aura = 425734,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425735] = {
            aura = 425735,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425736] = {
            aura = 425736,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [425737] = {
            aura = 425737,
            periodo = 3,
            prisa = false,
            duracion = 12,
            familia = 9,
            mascara = { 16384, 0, 0, 0 },
        }, -- Serpent Sting
        [426320] = {
            aura = 426320,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 5,
            mascara = { 0, 65536, 0, 0 },
        }, -- Shadowflame
        [426325] = { aura = 426325, periodo = 2, prisa = false, duracion = 8, familia = 5, mascara = { 0, 0, 2, 0 } }, -- Shadowflame
        [1235826] = {
            aura = 1235826,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 7,
            mascara = { 0, 256, 0, 0 },
        }, -- Lacerate
        [1235827] = {
            aura = 1235827,
            periodo = 3,
            prisa = false,
            duracion = 15,
            familia = 7,
            mascara = { 0, 256, 0, 0 },
        }, -- Lacerate
        [1237312] = {
            aura = 1237312,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 3,
            mascara = { 1074790400, 4096, 8, 0 },
        }, -- Frostfire Bolt
        [1237313] = {
            aura = 1237313,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 3,
            mascara = { 1074790400, 4096, 8, 0 },
        }, -- Frostfire Bolt
        [1265038] = {
            aura = 1265038,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265039] = {
            aura = 1265039,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265040] = {
            aura = 1265040,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265041] = {
            aura = 1265041,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265042] = {
            aura = 1265042,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265043] = {
            aura = 1265038,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265045] = {
            aura = 1265039,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265046] = {
            aura = 1265040,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265047] = {
            aura = 1265041,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265048] = {
            aura = 1265042,
            periodo = 3,
            prisa = false,
            duracion = 9,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Tendon Rip
        [1265065] = {
            aura = 1265065,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265066] = {
            aura = 1265066,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265067] = {
            aura = 1265067,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265068] = {
            aura = 1265068,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265069] = {
            aura = 1265069,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265831] = {
            aura = 1265065,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265833] = {
            aura = 1265066,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265834] = {
            aura = 1265067,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265835] = {
            aura = 1265068,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265836] = {
            aura = 1265069,
            periodo = 3,
            prisa = false,
            duracion = 18,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Savage Rend
        [1265843] = {
            aura = 1265843,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265878] = {
            aura = 1265878,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265880] = {
            aura = 1265880,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265881] = {
            aura = 1265881,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265883] = {
            aura = 1265883,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265887] = {
            aura = 1265843,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265888] = {
            aura = 1265878,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265890] = {
            aura = 1265880,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265891] = {
            aura = 1265881,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1265892] = {
            aura = 1265883,
            periodo = 1,
            prisa = false,
            duracion = 4,
            familia = 9,
            mascara = { 0, 268435456, 0, 0 },
        }, -- Web
        [1299332] = {
            aura = 1299332,
            periodo = 3,
            prisa = false,
            duracion = 21,
            familia = 9,
            mascara = { 0, 4096, 0, 0 },
        }, -- Lacerate
    },
    -- Talentos pasivos que cambian el ritmo de ticks (operación 19, Period): pct sobre el periodo.
    ritmos = {},
}
