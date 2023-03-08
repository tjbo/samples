open ReactNative
open Style
open Js.Array2
open Types

let screen = ReactNative.Dimensions.get(#screen)
let minY = 25.
let maxY = screen.height -. 220.

let styles = StyleSheet.create({
  "coverTop": Style.viewStyle(
    ~position=#absolute,
    ~top=-50.0->dp,
    ~bottom=50.0->dp,
    ~height=100.->dp,
    ~width=100.->pct,
    ~zIndex=-1,
    (),
  ),
  "handleExtrasContainer": Style.viewStyle(
    ~position=#absolute,
    ~width=100.->pct,
    ~top=Design.Size.sixteen->dp,
    ~flexDirection=#row,
    ~alignContent=#center,
    ~justifyContent=#center,
    (),
  ),
  "exampleImageContainer": Style.viewStyle(
    ~height=Design.Size.thirtyTwo->dp,
    ~marginLeft=Design.Size.two->dp,
    (),
  ),
  "exampleImage": Style.viewStyle(
    ~backgroundColor="transparent",
    ~height=(Design.Size.twentyFour +. Design.Size.six)->dp,
    ~marginTop=-15.->dp,
    ~width=(Design.Size.twentyFour +. Design.Size.six)->dp,
    (),
  ),
  "timerContainer": Style.viewStyle(~margin=Design.Size.four->dp, ()),
  "textContainer": Style.style(
    ~position=#absolute,
    ~top=30.->dp,
    ~zIndex=9,
    ~padding=Design.Size.four->dp,
    ~flexDirection=#row,
    ~width=100.->pct,
    ~justifyContent=#"space-around",
    (),
  ),
  "text": Style.textStyle(
    ~fontFamily=Design.Font.Family.regular,
    ~fontSize=Design.Font.Size.xl2,
    ~color=Design.Color.black,
    ~paddingLeft=Design.Size.three->dp,
    (),
  ),
  "clockContainer": Style.viewStyle(
    ~flexDirection=#column,
    ~alignContent=#center,
    ~minWidth=100.->pct,
    (),
  ),
  "clockText": Style.textStyle(
    ~fontFamily=Design.Font.Family.regular,
    ~fontSize=Design.Font.Size.xl3,
    ~color=Design.Color.black,
    ~textAlign=#center,
    ~width=100.->pct,
    (),
  ),
  "handle": Style.viewStyle(
    ~position=#absolute,
    ~justifyContent=#center,
    ~alignItems=#center,
    ~alignContent=#center,
    ~backgroundColor=Design.Color.Blue._800,
    ~height=Design.Size.sixteen->dp,
    ~width=100.->pct,
    ~top=50.0->dp,
    ~transform=[translateY(~translateY=minY)],
    (),
  ),
})

let selectableShortTimes = [
  3.0,
  4.0,
  5.0,
  6.0,
  7.0,
  8.0,
  9.0,
  10.0,
  15.0,
  20.0,
  25.0,
  30.0,
  35.0,
  40.0,
  45.0,
  50.0,
  55.0,
  60.0,
  70.0,
  80.0,
  90.0,
  100.0,
  110.0,
  120.0,
  135.0,
  150.0,
  165.0,
  180.0,
  195.0,
  210.0,
  225.0,
  240.0,
  255.0,
  270.0,
  285.0,
  300.0,
  330.0,
  360.0,
  390.0,
  420.0,
  450.0,
  480.0,
  510.0,
  540.0,
  570.0,
  600.0,
  630.0,
  660.0,
  690.0,
  720.0,
  750.0,
  780.0,
  810.0,
  840.0,
  870.0,
  900.0,
  930.0,
  960.0,
  990.0,
  1020.0,
]

let seletableMediumTimes = [
  1.0,
  2.0,
  3.0,
  4.0,
  5.0,
  6.0,
  7.0,
  8.0,
  9.0,
  10.0,
  11.0,
  12.0,
  13.0,
  14.0,
  15.0,
  16.0,
  17.0,
  18.0,
  19.0,
  20.0,
  25.0,
  30.0,
  35.0,
  40.0,
  45.0,
  50.0,
  55.0,
  60.0,
  75.0,
  90.0,
  105.0,
  120.0,
  135.0,
  150.0,
  165.0,
  180.0,
  195.0,
  210.0,
  225.0,
  240.0,
  255.0,
  270.0,
  285.0,
  300.0,
  315.0,
  330.0,
  345.0,
  360.0,
  375.0,
  390.0,
  405.0,
  420.0,
  435.0,
  450.0,
  465.0,
  480.0,
  495.0,
  510.0,
  525.0,
  540.0,
  555.0,
  570.0,
  585.0,
  600.0,
]

let selectableLongTimes = [
  1.0,
  2.0,
  3.0,
  4.0,
  5.0,
  6.0,
  7.0,
  8.0,
  9.0,
  10.0,
  11.0,
  12.0,
  13.0,
  14.0,
  15.0,
  16.0,
  17.0,
  18.0,
  19.0,
  20.0,
  21.0,
  22.0,
  23.0,
  24.0,
  25.0,
  26.0,
  27.0,
  28.0,
  29.0,
  30.0,
  31.0,
  32.0,
  33.0,
  34.0,
  35.0,
  36.0,
  37.0,
  38.0,
  39.0,
  40.0,
  41.0,
  42.0,
  43.0,
  44.0,
  45.0,
  46.0,
  47.0,
  48.0,
  49.0,
  50.0,
  51.0,
  52.0,
  53.0,
  50.0,
  55.0,
  56.0,
  57.0,
  58.0,
  59.0,
  60.0,
  61.0,
  62.0,
  63.0,
  64.0,
  65.0,
  66.0,
  67.0,
  68.0,
  69.0,
  70.0,
  71.0,
  72.0,
]

let selectableRepeaters = [
  0.0,
  2.0,
  3.0,
  4.0,
  5.0,
  6.0,
  7.0,
  8.0,
  9.0,
  10.0,
  11.0,
  12.0,
  13.0,
  14.0,
  15.0,
  16.0,
  17.0,
]

@react.component
let make = (~setScreen) => {
  let appState = AppContext.useAppState()
  let dispatch = EditorContext.useEditorDispatch()
  let state = EditorContext.useEditorState()
  let rangeSelector = state.rangeSelector

  let (val, name, items, darkColor, lightColor, extraLightColor) = switch rangeSelector {
  | TimerType(timerType) =>
    switch state.currentIds {
    | Some(_currentIds) => {
        let (intervalId, intervalGroupId) = _currentIds
        let currentInterval = EditorStore.getIntervalByIds(~intervalId, ~intervalGroupId, ~state)

        switch currentInterval {
        | Some(currentInterval) => {
            let totalTime = currentInterval.totalTime

            let (selectableTimes, initialValue) = switch timerType {
            | #Short => (selectableShortTimes, totalTime /. 1000.0)
            | #Medium => (selectableShortTimes, totalTime /. 1000.0 /. 60.0)
            | #Long => (selectableLongTimes, totalTime /. 60.0 /. 60.0 /. 1000.0)
            }

            let darkColor = Design.Color.getColorScheme(currentInterval.colorScheme)
            let lightColor = Design.Color.getColorSchemeLight(currentInterval.colorScheme)
            let extraLightColor = Design.Color.getColorSchemeExtraLight(currentInterval.colorScheme)

            (
              initialValue,
              currentInterval.name,
              selectableTimes,
              darkColor,
              lightColor,
              extraLightColor,
            )
          }

        | None => (
            0.0,
            "Invalid interval id",
            [0.0],
            Design.Color.Blue._800,
            Design.Color.Blue._300,
            Design.Color.Blue._50,
          )
        }
      }

    | None => (
        0.0,
        "Invalid interval id",
        [0.0],
        Design.Color.Blue._800,
        Design.Color.Blue._300,
        Design.Color.Blue._50,
      )
    }
  | Repeater =>
    switch state.currentIds {
    | Some(_currentIds) => {
        let (intervalId, intervalGroupId) = _currentIds

        let currentIntervalGroup = TimerUtils.getIntervalGroupById(
          ~intervalGroupId,
          ~timer=state.timer,
        )
        (
          currentIntervalGroup.repeatCount,
          "Repeater",
          selectableRepeaters,
          Design.Color.Blue._800,
          Design.Color.Blue._300,
          Design.Color.Blue._50,
        )
      }

    | None => (
        0.0,
        "Invalid interval id",
        [0.0],
        Design.Color.Blue._800,
        Design.Color.Blue._300,
        Design.Color.Blue._50,
      )
    }
  }

  let initalHeight = LinearInterpolation.range(
    1.0,
    Belt.Int.toFloat(Js.Array2.length(items)),
    minY,
    maxY,
    Belt.Int.toFloat(
      items->findIndex(t => {
        val === t
      }),
    ),
  )

  let offset = React.useRef(Animated.Value.create(0.)).current
  let initialTop = React.useRef(Animated.Value.create(initalHeight +. minY)).current
  let zero = React.useRef(Animated.Value.create(0.)).current
  let top = React.useRef(Animated.Value.create(113.)).current
  let _val = Animated.Value.add(initialTop, offset)
  let handleOpacityValue = React.useRef(Animated.Value.create(1.)).current
  let handleAnimation = React.useRef(
    Animated.loop(
      Animated.sequence([
        Animated.timing(
          handleOpacityValue,
          Animated.Value.Timing.config(
            ~toValue=0.70->Animated.Value.Timing.fromRawValue,
            ~duration=700.0,
            ~useNativeDriver=false,
            (),
          ),
        ),
        Animated.timing(
          handleOpacityValue,
          Animated.Value.Timing.config(
            ~toValue=1.0->Animated.Value.Timing.fromRawValue,
            ~duration=2000.0,
            ~useNativeDriver=false,
            (),
          ),
        ),
      ]),
    ),
  )

  React.useEffect0(() => {
    let listener = offset->Animated.Value.addListener(value => {
      let selectorIndex = LinearInterpolation.range(
        minY,
        maxY,
        1.0,
        Belt.Int.toFloat(Js.Array2.length(items)),
        %raw("initialTop._value + offset._value"),
      )

      switch rangeSelector {
      | TimerType(timerType) =>
        switch timerType {
        | #Short => dispatch(SetIntervalTime(items[Belt.Float.toInt(selectorIndex) - 1] *. 1000.0))
        | #Medium =>
          dispatch(SetIntervalTime(items[Belt.Float.toInt(selectorIndex) - 1] *. 1000.0 *. 60.0))
        | #Long =>
          dispatch(
            SetIntervalTime(items[Belt.Float.toInt(selectorIndex) - 1] *. 60.0 *. 60.0 *. 1000.0),
          )
        }
      | Repeater => {
          let nextValue = switch Belt.Float.toInt(selectorIndex) {
          | 0 => 0.0
          | _ => selectableRepeaters[Belt.Float.toInt(selectorIndex) - 1]
          }

          // Js.log2(Belt.Float.toInt(selectorIndex))
          dispatch(SetRepeater(nextValue))
        }
      }
    })
    handleAnimation.current->Animated.start()

    Some(_ => offset->Animated.Value.removeListener(listener))
  })

  let config = React.useRef(
    ReactNative.PanResponder.config(
      ~onMoveShouldSetPanResponder=(_e, _g) => true,
      ~onStartShouldSetPanResponder=(_e, _g) => true,
      ~onPanResponderStart=(_e, _g) => {
        handleAnimation.current->Animated.stop
        handleOpacityValue->Animated.Value.setValue(1.0)
      },
      ~onPanResponderMove=(_e, _g) => {
        offset->Animated.Value.setValue(_g.dy)
      },
      ~onPanResponderRelease=(_e, _g) => {
        let changeScreen = () => {
          ReactNativeBackgroundTimer.backgroundTimer->ReactNativeBackgroundTimer.setTimeout(() => {
            setScreen(Editor)
          }, 100.0)->ignore
        }

        // animated doesn't seem to have a way to convert an animated value back to a float
        let _initialTop = _g.dy +. %raw("initialTop._value")

        initialTop->Animated.Value.setValue(_initialTop)
        offset->Animated.Value.setValue(0.)

        if _initialTop < minY {
          Animated.spring(
            initialTop,
            Animated.Value.Spring.config(
              ~toValue=(25.0 +. minY)->Animated.Value.Spring.fromRawValue,
              ~useNativeDriver=false,
              ~overshootClamping=true,
              (),
            ),
          )->Animated.start(~endCallback=_ => changeScreen(), ())
        } else if _initialTop > maxY {
          Animated.spring(
            initialTop,
            Animated.Value.Spring.config(
              ~toValue=maxY->Animated.Value.Spring.fromRawValue,
              ~useNativeDriver=false,
              ~overshootClamping=true,
              (),
            ),
          )->Animated.start(~endCallback=_ => changeScreen(), ())
        } else {
          changeScreen()
        }
      },
      (),
    ),
  ).current

  let panResponder = React.useRef(PanResponder.create(config)).current
  let panHandlers = React.useRef(panResponder->PanResponder.panHandlers).current

  let animatedHandleStyle = Style.viewStyle(
    ~opacity=handleOpacityValue->Animated.StyleProp.float,
    ~transform=[translateY(~translateY=_val->Animated.StyleProp.float)],
    (),
  )

  let h = initialTop < zero ? 50.0 : Animated.Value.add(_val, top)->Animated.StyleProp.float
  let animatedContainerStyle = Style.viewStyle(~height=h->dp, ())
  let customHandleColorStyle = Style.viewStyle(~backgroundColor=darkColor, ())
  let customBackgroundColorStyle = Style.viewStyle(~backgroundColor=lightColor, ())
  let customBackgroundColorExtraLightStyle = Style.viewStyle(~backgroundColor=extraLightColor, ())

  let gestureImageYStyle = Style.viewStyle(~top=0.->dp, ())

  let clock = () => {
    <View style={styles["timerContainer"]}>
      <Text style={styles["clockText"]}>
        {switch rangeSelector {
        | Repeater => React.string(Belt.Float.toString(val) ++ "x")
        | TimerType(timerType) =>
          let _time = switch timerType {
          | #Short => val *. 1000.0
          | #Medium => val *. 1000.0 *. 60.0
          | #Long => val *. 60.0 *. 60.0 *. 1000.0
          }

          let (hours, minutes, seconds) = TimersStore.convertToHumanTime(_time)
          switch timerType {
          | #Short =>
            React.string(minutes ++ ":" ++ seconds ++ (_time >= 60000.0 ? " mins" : " secs"))
          | #Medium =>
            React.string(hours ++ ":" ++ minutes ++ (_time >= 3600000.0 ? " hrs" : " mins"))
          | #Long => React.string(hours ++ " hrs")
          }
        }}
      </Text>
    </View>
  }

  let uriSource = Image.Source.fromUriSource(Image.uriSource(~uri=ExampleImage.uri, ()))

  let example = () => {
    appState.isOnboarding
      ? <View
          style={array([gestureImageYStyle, styles["exampleImageContainer"]])} pointerEvents=#none>
          <Image style={styles["exampleImage"]} source={uriSource} />
          <View>
            <Text> {React.string("Drag bar to adjust time")} </Text>
          </View>
        </View>
      : React.null
  }

  <Screen>
    <Screen.Body>
      <View style={array([customBackgroundColorExtraLightStyle])}>
        <View style={styles["coverTop"]} />
        <Animated.View style={array([customBackgroundColorStyle, animatedContainerStyle])} />
        <Animated.View
          style={array([styles["handle"], customHandleColorStyle, animatedHandleStyle])}
          onMoveShouldSetResponder={panHandlers->PanResponder.onMoveShouldSetResponder}
          onStartShouldSetResponder={panHandlers->PanResponder.onStartShouldSetResponder}
          onResponderMove={event => {
            panHandlers->PanResponder.onResponderMove(event)
          }}
          onResponderStart={panHandlers->PanResponder.onResponderStart}
          onResponderRelease={panHandlers->PanResponder.onResponderRelease}>
          <Icons.DragHandle />
          <View style={styles["handleExtrasContainer"]}>
            {example()}
            {clock()}
          </View>
        </Animated.View>
      </View>
    </Screen.Body>
  </Screen>
}
