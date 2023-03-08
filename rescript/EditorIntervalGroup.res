open ReactNative
open Style

let screen = ReactNative.Dimensions.get(#screen)

let styles = StyleSheet.create({
  "container": Style.viewStyle(~marginBottom=Design.Size.five->dp, ()),
  "repeaterContainer": Style.viewStyle(
    ~width=screen.width->dp,
    ~marginBottom=Design.Size.five->dp,
    (),
  ),
  "titleContainer": Style.viewStyle(
    ~flexDirection=#column,
    ~justifyContent=#"flex-end",
    ~borderBottomWidth=StyleSheet.hairlineWidth,
    ~borderBottomColor=Design.Color.BlueGray._700,
    ~padding=Design.Size.two->dp,
    ~height=Design.Size.sixteen->dp,
    (),
  ),
  "title": Style.textStyle(
    ~color=Design.Color.CoolGray._600,
    ~fontSize=Design.Font.Size.xl,
    ~textAlign=#left,
    (),
  ),
})

let borderColor = Design.Color.BlueGray._500
let borderColorAsRgb = HexToRGB.make(Design.Color.getColorScheme(#BlueGray))
let backgroundColorAsRgb = HexToRGB.make(Design.Color.white)
let darkBackgroundColorAsRgb = HexToRGB.make(Design.Color.Blue._50)
let backgroundColorFlashAsRgb = HexToRGB.make(Design.Color.getColorScheme(#CoolGray))

@react.component
let make = (
  ~animatedOpacity,
  ~animatedWidth,
  ~animatedX,
  ~data: Types.intervalGroup,
  ~index,
  ~changedId: option<Types.intervalId>,
  ~isEditMode,
  ~selectedIntervalIds,
  ~selectInterval,
  ~setScreen,
  ~unselectInterval,
  ~timerType,
) => {
  let dispatch = EditorContext.useEditorDispatch()

  <View>
    <View style={styles["titleContainer"]} key={data.id ++ Belt.Int.toString(index)}>
      <Text style={styles["title"]}> {React.string("Set " ++ Belt.Int.toString(index + 1))} </Text>
    </View>
    {Belt.Array.map(data.intervals, interval => {
      <EditorInterval
        animatedOpacity={animatedOpacity}
        animatedX={animatedX}
        animdatedWidth={animatedWidth}
        key={interval.id}
        data={interval}
        intervalGroupId={data.id}
        isChanged={interval.id ===
          changedId->Belt.Option.mapWithDefault("", changedId => changedId)}
        isEditMode={isEditMode}
        isSelected={Belt.Array.some(selectedIntervalIds, intervalId => intervalId === interval.id)}
        selectInterval={selectInterval}
        setScreen={setScreen}
        timerType={timerType}
        unselectInterval={unselectInterval}
      />
    })->React.array}
    {data.repeatCount > 0.0
      ? <View>
          <EditorRepeater
            count={data.repeatCount}
            index={index}
            intervalGroupId={data.id}
            isChanged={data.id ===
              changedId->Belt.Option.mapWithDefault("", changedId => changedId)}
            isEditMode={isEditMode}
            selectRepeater={_ => dispatch(SelectRepeater(data.id))}
            setScreen={setScreen}
            unselectRepeater={_ => dispatch(UnselectRepeater(data.id))}
          />
        </View>
      : React.null}
  </View>
}
