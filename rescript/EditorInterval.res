open ReactNative
open Types
open Style
open Icons
let _screen = ReactNative.Dimensions.get(#screen)
let width1 = _screen.width /. 3.5
let width2 = width1 *. 2.0

let borderColor = Design.Color.BlueGray._500
let borderColorAsRgb = HexToRGB.make(Design.Color.getColorScheme(#BlueGray))
let backgroundColorAsRgb = HexToRGB.make(Design.Color.white)
let darkBackgroundColorAsRgb = HexToRGB.make(Design.Color.Blue._50)
let backgroundColorFlashAsRgb = HexToRGB.make(Design.Color.Blue._200)

let styles = StyleSheet.create({
  "container": Style.viewStyle(
    ~display=#flex,
    ~backgroundColor=Design.Color.white,
    ~borderBottomWidth=StyleSheet.hairlineWidth,
    ~borderBottomColor=borderColor,
    ~flexDirection=#row,
    ~height=Design.Size.eighteen->dp,
    ~margin=0.->dp,
    (),
  ),
  "clockColumn": Style.viewStyle(
    ~flexDirection=#row,
    ~flexGrow=1.,
    ~alignContent=#center,
    ~alignItems=#center,
    ~justifyContent=#"flex-end",
    ~minWidth=100.->pct,
    ~paddingRight=Design.Size.one->dp,
    ~borderBottomWidth=StyleSheet.hairlineWidth,
    ~borderBottomColor=borderColor,
    (),
  ),
  "colorBox": Style.viewStyle(
    ~backgroundColor=Design.Color.Amber._700,
    ~width=Design.Size.thirteen->dp,
    ~borderColor=Design.Color.black,
    ~margin=Design.Size.one->dp,
    (),
  ),
  "radioColumn": Style.viewStyle(
    ~flexDirection=#column,
    ~alignContent=#center,
    ~justifyContent=#center,
    (),
  ),
  "titleColumn": Style.viewStyle(
    ~flexDirection=#row,
    ~paddingLeft=Design.Size.one->dp,
    ~alignItems=#center,
    (),
  ),
  "button": Style.viewStyle(
    ~alignContent=#center,
    ~alignItems=#center,
    ~alignSelf=#center,
    ~flexDirection=#row,
    ~height=Design.Size.eighteen->dp,
    (),
  ),
  "buttonLeft": Style.viewStyle(
    ~flexDirection=#column,
    ~alignItems=#"flex-start",
    ~alignContent=#center,
    ~alignSelf=#center,
    ~justifyContent=#center,
    ~flexGrow=1.0,
    (),
  ),
  "buttonRight": Style.viewStyle(
    ~height=Design.Size.eighteen->dp,
    ~flexDirection=#column,
    ~flexBasis=width1->dp,
    ~backgroundColor=Design.Color.Blue._50,
    ~alignContent=#"flex-end",
    ~alignItems=#"flex-end",
    ~justifyContent=#center,
    (),
  ),
  "intervalClock": Style.textStyle(
    ~color=Design.Color.Blue._700,
    ~fontSize=Design.Font.Size.lg,
    (),
  ),
  "title": Style.style(~fontSize=Design.Font.Size.lg, ~color=Design.Color.Blue._700, ()),
})

@react.component
let make = (
  ~animatedX,
  ~animatedOpacity,
  ~animdatedWidth,
  ~data: interval,
  ~intervalGroupId,
  ~isChanged,
  ~isEditMode,
  ~isSelected,
  ~selectInterval,
  ~unselectInterval,
  ~setScreen,
  ~timerType,
) => {
  let colorScheme = data.colorScheme
  let id = data.id
  let intervalGroupId = intervalGroupId
  let name = data.name
  let time = data.totalTime
  let dispatch = EditorContext.useEditorDispatch()
  let (hours, minutes, seconds) = TimersStore.convertToHumanTime(time)
  let isChangedValue = React.useRef(Animated.Value.create(0.0)).current

  React.useEffect1(() => {
    let animation = Animated.timing(
      isChangedValue,
      Animated.Value.Timing.config(
        ~toValue=1.0->Animated.Value.Timing.fromRawValue,
        ~duration=1900.0,
        ~useNativeDriver=false,
        (),
      ),
    )

    if isChanged && !isEditMode {
      animation->Animated.start(~endCallback=_ => {
        isChangedValue->Animated.Value.setValue(0.0)
      }, ())
    }

    Some(
      _ => {
        animation->Animated.stop
      },
    )
  }, [isChanged])

  let updatedValueBackgroundColor1 = React.useRef(
    Animated.Value.interpolate(
      isChangedValue,
      Animated.Interpolation.config(
        ~inputRange=[0.0, 0.00001, 0.8],
        ~outputRange=[
          backgroundColorAsRgb,
          backgroundColorFlashAsRgb,
          backgroundColorAsRgb,
        ]->Animated.Interpolation.fromStringArray,
        (),
      ),
    ),
  ).current

  let backgroundColorStyle = Style.viewStyle(
    ~backgroundColor=updatedValueBackgroundColor1->Animated.StyleProp.unsafeAny,
    (),
  )

  let colorBoxStyle = Style.viewStyle(~backgroundColor=Design.Color.getColorScheme(colorScheme), ())

  let containerAnimatedStyle = Style.viewStyle(
    ~width=animdatedWidth->Animated.StyleProp.float->dp,
    ~transform=[translateX(~translateX=animatedX->Animated.StyleProp.float)],
    (),
  )

  let reverseOpacityAnimatedStyle = Style.viewStyle(
    ~opacity=animatedOpacity->Animated.StyleProp.float,
    (),
  )

  <Animated.View style={array([styles["container"], containerAnimatedStyle, backgroundColorStyle])}>
    <Animated.View style={array([styles["radioColumn"], reverseOpacityAnimatedStyle])}>
      <Radio
        isSelected={isSelected}
        onSelect={bool => {
          switch bool {
          | true => selectInterval(id)
          | false => unselectInterval(id)
          }
        }}
      />
    </Animated.View>
    <TouchableOpacity
      onPress={_ => {
        dispatch(SetCurrentIds(id, intervalGroupId))
        setScreen(EditorName)
      }}
      style={array([styles["button"], styles["buttonLeft"]])}>
      <Animated.View style={array([styles["titleColumn"]])}>
        <BackArrowIcon /> <Text style={styles["title"]}> {React.string(name)} </Text>
      </Animated.View>
    </TouchableOpacity>
    <TouchableOpacity
      onPress={_ => {
        dispatch(SetCurrentIds(id, intervalGroupId))
        setScreen(EditorColor)
      }}
      style={array([styles["colorBox"], colorBoxStyle])}
    />
    <Animated.View style={array([styles["button"], styles["buttonRight"], backgroundColorStyle])}>
      <TouchableOpacity
        onPress={_ => {
          dispatch(SetCurrentIds(id, intervalGroupId))
          dispatch(SetRangeSelector(TimerType(timerType)))
          setScreen(EditorRangeSelector)
        }}>
        <View style={array([styles["clockColumn"]])}>
          {switch timerType {
          | #Short =>
            <Text style={styles["intervalClock"]}>
              {React.string(minutes)} {React.string(":")} {React.string(seconds)}
            </Text>
          | #Medium =>
            <Text style={styles["intervalClock"]}>
              {React.string(hours)}
              {React.string(":")}
              {React.string(minutes)}
              {React.string(time >= 3600000.0 ? " h" : " m")}
            </Text>
          | #Long =>
            <Text style={styles["intervalClock"]}>
              {React.string(hours)} {React.string(" hours")}
            </Text>
          }}
          <ForwardArrowIcon />
        </View>
      </TouchableOpacity>
    </Animated.View>
  </Animated.View>
}
