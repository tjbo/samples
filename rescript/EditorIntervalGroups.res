open ReactNative
open Style

let screen = ReactNative.Dimensions.get(#screen)

let styles = StyleSheet.create({
  "container": Style.viewStyle(
    ~flex=1.0,
    ~width=screen.width->dp,
    ~flexDirection=#column,
    ~justifyContent=#"flex-start",
    ~alignContent=#"flex-start",
    ~alignItems=#"flex-start",
    (),
  ),
})

@react.component
let make = (~createNewInterval, ~setScreen) => {
  let state = EditorContext.useEditorState()
  let appState = AppContext.useAppState()
  let dispatch = EditorContext.useEditorDispatch()
  let animatedValue = React.useRef(Animated.Value.create(0.0)).current

  React.useEffect1(_ => {
    let createAnimation = (val: float) => {
      Animated.timing(
        animatedValue,
        Animated.Value.Timing.config(
          ~toValue=val->Animated.Value.Timing.fromRawValue,
          ~duration=300.0,
          ~useNativeDriver=false,
          (),
        ),
      )
    }

    let animation = switch appState.isEditMode {
    | true => 1.0->createAnimation
    | false => 0.0->createAnimation
    }

    animation->Animated.start()

    Some(
      _ => {
        animation->Animated.stop
      },
    )
  }, [appState.isEditMode])

  let animatedOpacity = React.useRef(
    Animated.Value.interpolate(
      animatedValue,
      Animated.Interpolation.config(
        ~inputRange=[0.0, 1.0],
        ~outputRange=[0.0, 1.0]->Animated.Interpolation.fromFloatArray,
        (),
      ),
    ),
  ).current

  let animatedX = React.useRef(
    Animated.Value.interpolate(
      animatedValue,
      Animated.Interpolation.config(
        ~inputRange=[0.0, 1.0],
        ~outputRange=[-.Design.Size.thirteen, 0.0]->Animated.Interpolation.fromFloatArray,
        (),
      ),
    ),
  ).current

  let animatedWidth = React.useRef(
    Animated.Value.interpolate(
      animatedValue,
      Animated.Interpolation.config(
        ~inputRange=[0.0, 1.0],
        ~outputRange=[
          screen.width +. Design.Size.thirteen *. 1.0,
          screen.width,
        ]->Animated.Interpolation.fromFloatArray,
        (),
      ),
    ),
  ).current

  <View style={styles["container"]}>
    {switch Belt.Array.length(state.timer.intervalGroups) > 0 {
    | true =>
      Belt.Array.mapWithIndex(state.timer.intervalGroups, (index, intervalGroup) => {
        <EditorIntervalGroup
          animatedOpacity={animatedOpacity}
          animatedWidth={animatedWidth}
          animatedX={animatedX}
          data={intervalGroup}
          index={index}
          changedId={state.changedId}
          isEditMode={appState.isEditMode}
          selectedIntervalIds={state.selectedIntervalIds}
          selectInterval={id => dispatch(SelectInterval(id))}
          setScreen={setScreen}
          unselectInterval={id => dispatch(UnselectInterval(id))}
          timerType={state.timer.timerType}
        />
      })->React.array

    | false => <EditorEmpty createNewInterval={createNewInterval} />
    }}
  </View>
}
