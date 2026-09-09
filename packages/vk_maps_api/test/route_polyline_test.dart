import 'package:test/test.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

/// Настоящий ответ сервиса маршрутизации VK Карт: маршрут по Москве,
/// 23.5 км, 334 точки. Строка вшита в тест намеренно — на синтетических
/// примерах из трёх точек ошибка декодера в браузере не проявляется.
const String _moscowRoute =
    r'''ydqliBeqcrfA_KyO_AyA{EsHp]obA|BqGfDkJl[g_Ad[q~@nO}d@bt@stBtM}_@`CiHvUmr@zAsF\yEBcEKyDg@sDgAcDgKyPaBsA_Bc@iBEuBj@oBjBoDhFuOhf@mWlu@kCzH}d@`tA}f@fxAwTlo@mk@`bBuU|q@sKh[uCnIcAtCoGlTyXxbAoBdH}z@beC{Ujq@{Off@{Kj\mAnDyGpUuFxQoHv]wGz]mGj_@qFr^mHrf@o^nyBiLzr@}SdkAeO`z@{BhMgK`p@sUp~AqTbwA{CxS}Ktt@wPbtAmQpwAoGfe@mFt^c`@r`C_I|e@aUfuAsJjl@wGn`@qDbSgDfPsCxLsEjPmDnKeIzSmJrScGjLyFfKiEvGeE~FeEjFiFvFwFhFaEjDiEbDqdAvu@aqDjpCag@x_@WRalBxxA}n@vf@qlCzoBcBhAic@b\oqDfnCaa@bYkAx@qj@b^}b@p[umA`aAu|@dq@ikAdcAy\tXwu@tm@}mA`aAua@~[kXxSuVhR{@p@ev@`l@{^zXaBrAiMtJ{QjNab@x[aMxJyaAzv@qjAp|@alAf|@arC~mBqbAdr@{fBtiAoFjDad@rYak@t^aQxKsy@vf@{e@|Xwo@l`@gnA|v@oo@f`@{gAbq@qx@pf@uk@r^}cBzcAup@|`@wW~Oyr@xb@adAvo@m_Avj@ie@xXyRtLcQlK_h@h[yLnHcTzMkv@xc@{q@pa@a\vRmm@f_@kAt@{WdQ_[tRa@T_h@p[qNjIcBbAehAhp@wh@v[mV|Ncu@lc@oj@t]_StLs\dS{VfOyI~EcWhOaOjJ}`@j[aKtKk\|]aW`]kVd_@gGhJyo@ddAsdCrwDw[jj@idApzA{|@rkAgZj_@_ApAsvAzdB}^~c@qi@pq@wrAzdB_n@vx@qFdHg|AftB_I`LoUj[GH_TnYuc@lo@{o@||@gc@rl@_e@xo@qb@pl@yHrKcVb\oIfLms@r`AuOjSak@xt@mThZu~@noAiw@leAaqBzlCcMfQssAveBczAprByw@|dA{z@ziAoc@pj@}m@v{@{fAjzAu^bf@}^fh@kYdc@yNrUsaAxdBeFjI}JzQqOfX}n@fhAo{ArmC__BxrCiTt]i`@xn@maAf~AyYfd@}d@|s@qq@bfAyUx]sZf`@}U~Wg`@ja@qc@n`@ujAz`Aua@t`@uWtY}Z~_@}b@xo@uNbUkX`i@eHfNuVd]yNrQeMjL}MfJwLvJeLfJelAxy@oMjJ_MlGkMxDyOpAgLk@mHs@aU{FwCeBuIeFcQgLe]_TkKsGob@sWk@_@_vD{_CsnDa|B}WsPahHqpEaBcAq~BayAsgDavB_i@e\g`HokEiViOmsBopA{}@_k@sn@oa@uVcM{LqFoEoByQeHwSuGw_@{JwSqCsTiB_U_A}V_@meAj@iv@v@_UTeNNmi@Mcm@h@}e@nBgi@@i|@KaQ]{Nc@{Km@uJu@kMoAef@kH}AMoL{@kD?gDLkEr@oDdBiDjCoDxDqCtEaCtFaCfI}AjIoAxKy@vMkLhsCk@nP]bOIfOV|OVrG`@vGnCfYpCx]nCd]bGfu@nFdq@nAtO''';

void main() {
  group('декодирование настоящего маршрута', () {
    // Тест имеет смысл гонять и в браузере:
    //   dart test -p chrome
    // Побитовая версия декодера проходила его на виртуальной машине и
    // уводила половину точек к полюсу в собранном для web приложении.
    test('все точки остаются в пределах маршрута', () {
      final List<VkGeoPoint> points = VkPolyline.decode(_moscowRoute);
      expect(points, hasLength(334));

      for (final VkGeoPoint point in points) {
        expect(point.latitude, inInclusiveRange(55.79, 55.97));
        expect(point.longitude, inInclusiveRange(37.39, 37.55));
      }
    });

    test('концы маршрута совпадают с заданными точками', () {
      final List<VkGeoPoint> points = VkPolyline.decode(_moscowRoute);
      expect(points.first.latitude, closeTo(55.796829, 1e-6));
      expect(points.first.longitude, closeTo(37.538083, 1e-6));
      expect(points.last.latitude, closeTo(55.962138, 1e-6));
      expect(points.last.longitude, closeTo(37.406377, 1e-6));
    });
  });
}
