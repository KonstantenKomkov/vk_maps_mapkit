<!-- Источник: https://dev.vk.ru/ru/vkmaps/routing/directions/response-example -->
<!-- Снято: 2026-09-08 -->

# Построение маршрута — Пример ответа

```json
{
    "trips":
    [
        {
            "trip":
            {
                "locations":
                [
                    {
                        "type": "break",
                        "lat": 55.796932,
                        "lon": 37.537849,
                        "heading": 150,
                        "city": "left",
                        "original_index": 0
                    },
                    {
                        "type": "via",
                        "lat": 55.865625,
                        "lon": 37.46229,
                        "original_index": 1
                    },
                    {
                        "type": "break",
                        "lat": 55.962139,
                        "lon": 37.406377,
                        "original_index": 2
                    }
                ],
                "legs":
                [
                    {
                        "maneuvers":
                        [
                            {
                                "type": 3,
                                "instruction": "Двигайтесь на северо-восток.",
                                "verbal_succinct_transition_instruction": "Двигайтесь на северо-запад., затем Поверните направо на Ленинградский проспект.",
                                "verbal_pre_transition_instruction": "Двигайтесь на северо-запад., затем Поверните направо на Ленинградский проспект.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 50 метров.",
                                "time": 8.72,
                                "length": 0.048,
                                "cost": 364.824,
                                "begin_shape_index": 0,
                                "end_shape_index": 3,
                                "verbal_multi_cue": true,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 10,
                                "instruction": "Поверните направо на Ленинградский проспект.",
                                "verbal_transition_alert_instruction": "Поверните направо на Ленинградский проспект.",
                                "verbal_succinct_transition_instruction": "Поверните направо.",
                                "verbal_pre_transition_instruction": "Поверните направо на Ленинградский проспект.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 600 метров.",
                                "street_names":
                                [
                                    "Ленинградский проспект"
                                ],
                                "time": 37.931,
                                "length": 0.593,
                                "cost": 72.21,
                                "begin_shape_index": 3,
                                "end_shape_index": 12,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 13,
                                "instruction": "Развернитесь налево, чтобы остаться на Ленинградский проспект.",
                                "verbal_transition_alert_instruction": "Развернитесь налево, чтобы остаться на Ленинградский проспект.",
                                "verbal_succinct_transition_instruction": "Развернитесь налево.",
                                "verbal_pre_transition_instruction": "Развернитесь налево, чтобы остаться на Ленинградский проспект.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 10 километров.",
                                "street_names":
                                [
                                    "Ленинградский проспект"
                                ],
                                "time": 535.509,
                                "length": 10.369,
                                "cost": 682.537,
                                "begin_shape_index": 12,
                                "end_shape_index": 164,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 23,
                                "instruction": "Держитесь правой стороны на развилке.",
                                "verbal_transition_alert_instruction": "Держитесь правой стороны на развилке.",
                                "verbal_pre_transition_instruction": "Держитесь правой стороны на развилке.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 400 метров.",
                                "time": 34.122,
                                "length": 0.378,
                                "cost": 55.773,
                                "begin_shape_index": 164,
                                "end_shape_index": 174,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 15,
                                "instruction": "Поверните налево.",
                                "verbal_transition_alert_instruction": "Поверните налево.",
                                "verbal_succinct_transition_instruction": "Поверните налево.",
                                "verbal_pre_transition_instruction": "Поверните налево.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 400 метров.",
                                "time": 45.832,
                                "length": 0.435,
                                "cost": 75.448,
                                "begin_shape_index": 174,
                                "end_shape_index": 195,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 9,
                                "instruction": "Поверните направо на Ленинградское шоссе.",
                                "verbal_transition_alert_instruction": "Поверните направо на Ленинградское шоссе.",
                                "verbal_succinct_transition_instruction": "Поверните направо., затем через 300 метров, Поверните направо.",
                                "verbal_pre_transition_instruction": "Поверните направо на Ленинградское шоссе., затем через 300 метров, Поверните направо.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 300 метров.",
                                "street_names":
                                [
                                    "Ленинградское шоссе"
                                ],
                                "time": 12.615,
                                "length": 0.289,
                                "cost": 28.807,
                                "begin_shape_index": 195,
                                "end_shape_index": 199,
                                "verbal_multi_cue": true,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 9,
                                "instruction": "Поверните направо.",
                                "verbal_transition_alert_instruction": "Поверните направо.",
                                "verbal_succinct_transition_instruction": "Поверните направо., затем через 50 метров, Поверните направо.",
                                "verbal_pre_transition_instruction": "Поверните направо., затем через 50 метров, Поверните направо.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 50 метров.",
                                "time": 9.245,
                                "length": 0.05,
                                "cost": 91.808,
                                "begin_shape_index": 199,
                                "end_shape_index": 201,
                                "verbal_multi_cue": true,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 9,
                                "instruction": "Поверните направо.",
                                "verbal_transition_alert_instruction": "Поверните направо.",
                                "verbal_succinct_transition_instruction": "Поверните направо.",
                                "verbal_pre_transition_instruction": "Поверните направо.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 100 метров.",
                                "time": 40.258,
                                "length": 0.123,
                                "cost": 759.908,
                                "begin_shape_index": 201,
                                "end_shape_index": 213,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 10,
                                "instruction": "Поверните направо.",
                                "verbal_transition_alert_instruction": "Поверните направо.",
                                "verbal_succinct_transition_instruction": "Поверните направо.",
                                "verbal_pre_transition_instruction": "Поверните направо.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 100 метров.",
                                "time": 24.898,
                                "length": 0.127,
                                "cost": 36.26,
                                "begin_shape_index": 213,
                                "end_shape_index": 217,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 15,
                                "instruction": "Поверните налево.",
                                "verbal_transition_alert_instruction": "Поверните налево.",
                                "verbal_succinct_transition_instruction": "Поверните налево., затем Поверните направо на Ленинградское шоссе.",
                                "verbal_pre_transition_instruction": "Поверните налево., затем Поверните направо на Ленинградское шоссе.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 20 метров.",
                                "time": 8.515,
                                "length": 0.018,
                                "cost": 22.563,
                                "begin_shape_index": 217,
                                "end_shape_index": 218,
                                "verbal_multi_cue": true,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 10,
                                "instruction": "Поверните направо на Ленинградское шоссе/Leningrad Avenue.",
                                "verbal_transition_alert_instruction": "Поверните направо на Ленинградское шоссе.",
                                "verbal_succinct_transition_instruction": "Поверните направо., затем Выезжайте на кольцевую развязку и сверните на 3-м съезде на Беломорская улица.",
                                "verbal_pre_transition_instruction": "Поверните направо на Ленинградское шоссе, Leningrad Avenue., затем Выезжайте на кольцевую развязку и сверните на 3-м съезде на Беломорская улица.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 80 метров.",
                                "street_names":
                                [
                                    "Ленинградское шоссе",
                                    "Leningrad Avenue"
                                ],
                                "time": 5.75,
                                "length": 0.081,
                                "cost": 20.979,
                                "begin_shape_index": 218,
                                "end_shape_index": 220,
                                "verbal_multi_cue": true,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 26,
                                "instruction": "Выезжайте на кольцевую развязку и сверните на 3-м съезде на Беломорская улица.",
                                "verbal_transition_alert_instruction": "Выезжайте на кольцевую развязку и сверните на 3-м съезде на Беломорская улица.",
                                "verbal_succinct_transition_instruction": "Выезжайте на кольцевую развязку и сверните на 3-м съезде.",
                                "verbal_pre_transition_instruction": "Выезжайте на кольцевую развязку и сверните на 3-м съезде на Беломорская улица.",
                                "time": 20.267,
                                "length": 0.255,
                                "cost": 19.688,
                                "begin_shape_index": 220,
                                "end_shape_index": 239,
                                "roundabout_exit_count": 3,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 27,
                                "instruction": "Сверните с кольцевой развязки на Беломорская улица.",
                                "verbal_succinct_transition_instruction": "Сверните с кольцевой развязки.",
                                "verbal_pre_transition_instruction": "Сверните с кольцевой развязки на Беломорская улица.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 200 метров.",
                                "street_names":
                                [
                                    "Беломорская улица"
                                ],
                                "time": 14.073,
                                "length": 0.189,
                                "cost": 24.333,
                                "begin_shape_index": 239,
                                "end_shape_index": 244,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 20,
                                "instruction": "Сверните на съезде на Ленинградское шоссе.",
                                "verbal_transition_alert_instruction": "Сверните на съезд на Ленинградское шоссе.",
                                "verbal_pre_transition_instruction": "Сверните на съезд на Ленинградское шоссе.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 8 километров.",
                                "street_names":
                                [
                                    "Ленинградское шоссе"
                                ],
                                "time": 394.793,
                                "length": 8.069,
                                "cost": 500.92,
                                "begin_shape_index": 244,
                                "end_shape_index": 355,
                                "sign":
                                {
                                    "exit_branch_elements":
                                    [
                                        {
                                            "text": "Ленинградское шоссе"
                                        }
                                    ]
                                },
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 23,
                                "instruction": "Держитесь правой стороны к Шереметьево-2.",
                                "verbal_transition_alert_instruction": "Держитесь правой стороны к Шереметьево-2.",
                                "verbal_pre_transition_instruction": "Держитесь правой стороны к Шереметьево-2.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 600 метров.",
                                "street_names":
                                [
                                    "46Н-13925"
                                ],
                                "time": 34.818,
                                "length": 0.578,
                                "cost": 38.3,
                                "begin_shape_index": 355,
                                "end_shape_index": 372,
                                "sign":
                                {},
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 24,
                                "instruction": "Держитесь прямо, чтобы свернуть на 46Н-13925/Международное шоссе.",
                                "verbal_transition_alert_instruction": "Держитесь левой стороны, чтобы свернуть на 46Н-13925.",
                                "verbal_pre_transition_instruction": "Держитесь левой стороны, чтобы свернуть на 46Н-13925, Международное шоссе.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 2.5 километров.",
                                "street_names":
                                [
                                    "46Н-13925",
                                    "Международное шоссе"
                                ],
                                "time": 89.576,
                                "length": 2.654,
                                "cost": 75.352,
                                "begin_shape_index": 372,
                                "end_shape_index": 384,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 24,
                                "instruction": "Держитесь левой стороны, чтобы остаться на 46Н-13925/Международное шоссе.",
                                "verbal_transition_alert_instruction": "Держитесь левой стороны, чтобы остаться на 46Н-13925.",
                                "verbal_pre_transition_instruction": "Держитесь левой стороны, чтобы остаться на 46Н-13925, Международное шоссе.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 1.5 километров.",
                                "street_names":
                                [
                                    "46Н-13925",
                                    "Международное шоссе"
                                ],
                                "time": 50.683,
                                "length": 1.254,
                                "cost": 46.611,
                                "begin_shape_index": 384,
                                "end_shape_index": 403,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 24,
                                "instruction": "Держитесь прямо к Шереметьево/ Терминал D.",
                                "verbal_transition_alert_instruction": "Держитесь левой стороны к Шереметьево.",
                                "verbal_pre_transition_instruction": "Держитесь левой стороны к Шереметьево, Терминал D.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 500 метров.",
                                "time": 33.139,
                                "length": 0.46,
                                "cost": 38.839,
                                "begin_shape_index": 403,
                                "end_shape_index": 413,
                                "sign":
                                {},
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 23,
                                "instruction": "Держитесь правой стороны на развилке.",
                                "verbal_transition_alert_instruction": "Держитесь правой стороны на развилке.",
                                "verbal_pre_transition_instruction": "Держитесь правой стороны на развилке.",
                                "verbal_post_transition_instruction": "Продолжайте движение еще 600 метров.",
                                "time": 43.991,
                                "length": 0.61,
                                "cost": 63.974,
                                "begin_shape_index": 413,
                                "end_shape_index": 439,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            },
                            {
                                "type": 4,
                                "instruction": "Вы прибыли в пункт назначения.",
                                "verbal_transition_alert_instruction": "Вы прибудете в пункт назначения.",
                                "verbal_pre_transition_instruction": "Вы прибыли в пункт назначения.",
                                "time": 0.0,
                                "length": 0.0,
                                "cost": 0.0,
                                "begin_shape_index": 439,
                                "end_shape_index": 439,
                                "travel_mode": "drive",
                                "travel_type": "car"
                            }
                        ],
                        "summary":
                        {
                            "ll_boxes":
                            [
                                {
                                    "min_lat": 55.79378,
                                    "min_lon": 37.39366,
                                    "max_lat": 55.962686,
                                    "max_lon": 37.546925
                                }
                            ],
                            "has_time_restrictions": false,
                            "time": 1444.743,
                            "length": 26.583,
                            "cost": 3019.145
                        },
                        "shape": "ydqliBeqcrfA_KyO_AyA{EsHv^aeA~FkPl[g_Ad[q~@nO}d@bt@stBtM}_@`CiHvUmr@zAsF\\yEBcEKyDg@sDgAcDgKyPaBsA_Bc@iBEuBj@oBjBoDhFuOhf@mWlu@kCzH}d@`tA}f@fxAwTlo@mk@`bBuU|q@sKh[uCnIcAtCoGlTwTzu@aDlJm}@xoC{Ujq@{Off@iNza@yGpUuFxQoHv]wGz]mGj_@qFr^mHrf@o^nyBiLzr@}SdkAeO`z@{BhMgK`p@wG`i@ka@pmC{QphAec@tlDoGfe@mFt^c`@r`C_I|e@aUfuAsJjl@wGn`@qDbSgDfPsCxLsEjPmDnKmFvNmBvFQj@eIjPcGjLyFnJiEvGeE~FeEjFiFvFwFhFaEjDiEbDmZbTyCdCyHnFc`@bYmkDdlCag@x_@WRalBxxA}n@vf@qlCzoBcBhAic@b\\{eD|dCao@fd@qj@b^}b@p[snAp~@u|@dq@}jAjbAs`@j^ii@pc@kGhFmmAv`A{a@n[uq@`j@mv@|k@}a@n[e`@`Zab@x[aMxJyaAzv@{`BfnAwu@pj@arC~mBqbAdr@{fBtiAoFjDad@rYak@t^aQxKsy@vf@{e@|Xwo@l`@gnA|v@oo@f`@ak@`]iz@ng@aZbRuk@r^}cBzcAup@|`@sf@hZs^xTkiAls@m_Avj@ie@xXyRtLcQlK_h@h[yLnHcTzMkv@xc@}nAhu@mm@f_@kAt@{WdQ_[tRa@T_h@p[qNjIcBbAehAhp@wh@v[mV|Ncu@lc@oj@t]_YvPsVbO{VfOcADkHVcs@dPsRlEs\\~F}GnBoFlCmFlDiJ|Jyq@rw@xBrMjDxN`FrOdShm@jAdC`CnBfCl@~CKdOoFrHsF~HsGhIaJ~C{DhKsJtH{KhGyOhTar@z@oCbFkSlCuHnE}IjAy@jNmJzu@ke@xlAiv@tT~@rEQlAdARPxCtCvC|KrA~JvAlAzLmHf@kDmB}N@_FsAyJWmBlOuJh]ySpJ_GdGwDqByOh\\_SbLyG`Hq@`ET`Dd@xCx@pnAn\\dCfA|@x@d@Fx@Kv@u@t@qBb@{CPoDAgEUeDg@{Ci@_C_AaCc@YuAgFcAaIcEyb@}Eme@oNowAk@ePF{H~@{DlCgGnC_DtC{@bCMxCn@|GjFlDtJxFnOz@hCnCzGfJjW|BxGXpCLdC?rCK|C_@lCaBnF}B`DkAt@{WdQ_[tRa@T_h@p[qNjIcBbAehAhp@wh@v[mV|Ncu@lc@oj@t]_YvPsVbO{VfOyI~EcWhOaOjJ}`@j[aKtKk\\|]aW`]kVd_@gGhJyo@ddAsdCrwDw[jj@idApzA{|@rkAgZj_@_ApAsvAzdB}^~c@qi@pq@}pArbBy@fA_n@vx@qFdHy@dAmzA`rB_I`LoUj[GH_TnYwb@ll@yp@|_Agc@rl@_e@xo@qb@pl@y_@bi@wPlTmh@hs@_UrYsi@hs@mThZkaAxrAst@bbActBhqCaJxLssAveBczAprByw@|dA{z@ziAqc@rj@{m@t{@ucAhvAiBbCq^`f@}^fh@kYdc@yNrUsaAxdBeFjI}JzQqOfX}n@fhAyyA~jCu`BluC}o@hfAegAjeBqZ`e@kd@tr@iq@rfAgz@xrAmnCllEiTd]}b@bq@_mBtyCus@`gAsZ~OyS|K{KvFaf@pVyM|G}IzBaG~@sHFcHa@}HqAmIyCqIaEmUmNuRqJkc@oWcQgLo[yRu@e@{n@g`@k@_@_vD{_CsnDa|B}WsPahHqpEaBcAegHcpE_i@e\\g`HokEiViOmsBopA{}@_k@sn@oa@uVcM{LqFoEoByQeHwSuGw_@{JwSqCsTiB_U_A}V_@meAj@iv@v@_UTeNNmi@Mcm@h@}e@nBgi@@i|@KaQ]{Nc@{Km@uJu@kMoAef@kH}AMoL{@kD?gDLkEr@oDdBiDjCoDxDqCtEaCtFaCfI}AjIoAxKy@vMkLhsCk@nP]bOIfOV|OVrG`@vGnCfYpCx]nCd]bGfu@nFdq@nAtO"
                    }
                ],
                "summary":
                {
                    "ll_boxes":
                    [
                        {
                            "min_lat": 55.79378,
                            "min_lon": 37.39366,
                            "max_lat": 55.962686,
                            "max_lon": 37.546925
                        }
                    ],
                    "has_time_restrictions": false,
                    "time": 1444.743,
                    "length": 26.583,
                    "cost": 3019.145
                }
            }
        }
    ],
    "ll_boxes":
    [
        {
            "min_lat": 55.79378,
            "min_lon": 37.39366,
            "max_lat": 55.962686,
            "max_lon": 37.546925
        }
    ],
    "status_message": "Found 1 route(s) between points",
    "status": 0,
    "units": "kilometers",
    "language": "ru-RU"
}
```
