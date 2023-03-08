open Types
open Js.Array2

// Number.MAX_VALUE in JavaScript (wasn't available in Rescript)
let MAX_NUMBER_VALUE = 1.7976931348623157e+308

type state = {
  currentIds: option<(id, intervalGroupId)>,
  selectedRepeaterIntervalGroupIds: array<intervalGroupId>,
  selectedIntervalIds: array<intervalId>,
  changedId: option<intervalId>,
  isDirty: bool,
  scrollTo: float,
  rangeSelector: rangeSelector,
  timer: timer,
}

let getCurrentIntervalGroupId = timer => {
  let intervalGroups = timer.intervalGroups
  intervalGroups[Belt.Array.length(intervalGroups) - 1].id
}

let initialState = {
  currentIds: None,
  changedId: None,
  isDirty: false,
  selectedIntervalIds: [],
  selectedRepeaterIntervalGroupIds: [],
  scrollTo: 0.0,
  rangeSelector: TimerType(#Short),
  timer: {
    currentSessionId: None,
    delayBetweenIntervals: 0.0,
    isMuted: false,
    totalElapsedTime: 0.0,
    createdAt: Js.Date.getTime(Js.Date.make()),
    currentIntervalIndex: 0,
    currentIntervalGroupIndex: 0,
    id: Uuid.V4.make(),
    name: "",
    _rev: None,
    prevNow: Js.Date.now(),
    status: #NotStarted,
    timerType: #Short,
    updatedAt: 0.0,
    userId: "",
    intervalGroups: [],
  },
}

let getIntervalByIds = (~intervalId, ~intervalGroupId, ~state) => {
  switch state.currentIds {
  | Some(_currentIds) => {
      let (intervalId, intervalGroupId) = _currentIds

      let currentIntervalGroup = TimerUtils.getIntervalGroupById(
        ~intervalGroupId,
        ~timer=state.timer,
      )

      let intervalIndex = Js.Array2.findIndex(currentIntervalGroup.intervals, interval => {
        interval.id === intervalId
      })

      Some(currentIntervalGroup.intervals[intervalIndex])
    }

  | None => None
  }
}

let cloneTimer = timer => {
  let newIntervalGroups =
    timer.intervalGroups
    ->Js.Array2.sliceFrom(0)
    ->map(intervalGroup => {
      {
        ...intervalGroup,
        intervals: intervalGroup.intervals->Js.Array2.sliceFrom(0),
      }
    })
  {
    ...timer,
    intervalGroups: newIntervalGroups,
  }
}

let getTimerAsPlaylist = (~state) => {
  let timer = state.timer
  let totalTime = ref(0.0)

  let newIntervalGroups =
    Belt.Array.copy(timer.intervalGroups)
    ->map(intervalGroup => {
      let multiplier = Js.Math.max_int(Belt.Float.toInt(intervalGroup.repeatCount), 1)
      let intervals = Belt.Array.make(multiplier, Belt.Array.copy(intervalGroup.intervals))
      let arr = Belt.Array.concatMany(intervals)

      let intervals = Belt.Array.copy(arr)->map(interval => {
        totalTime := totalTime.contents +. interval.totalTime
        {
          ...interval,
          id: Uuid.V4.make(),
          endTime: totalTime.contents,
        }
      })

      {
        ...intervalGroup,
        intervals,
      }
    })
    ->Belt.Array.keep(group => Belt.Array.length(group.intervals) > 0)

  {
    ...timer,
    status: #NotStarted,
    currentIntervalIndex: 0,
    currentIntervalGroupIndex: 0,
    totalElapsedTime: 0.0,
    intervalGroups: newIntervalGroups,
  }
}

let getTimerFromPlayList = (~timer) => {
  let newIntervalGroups = Belt.Array.copy(timer.intervalGroups)->map(intervalGroup => {
    let intervals = Belt.Array.copy(intervalGroup.intervals)->map(interval => {
      {
        ...interval,
        elapsedTime: 0.0,
      }
    })

    let numberOfIntervals = switch intervalGroup.repeatCount > 0.0 {
    | true => Belt.Array.length(intervals) / Belt.Float.toInt(intervalGroup.repeatCount)
    | false => Belt.Array.length(intervals)
    }

    {
      ...intervalGroup,
      intervals: Belt.Array.slice(intervals, ~offset=0, ~len=numberOfIntervals),
    }
  })

  {
    ...timer,
    totalElapsedTime: 0.0,
    currentIntervalIndex: 0,
    currentIntervalGroupIndex: 0,
    currentSessionId: None,
    status: #NotStarted,
    intervalGroups: newIntervalGroups,
  }
}

type action =
  | SetIntervalTime(time)
  | CreateRepeater
  | CreateInterval
  | CreateTimer(timerType, userId)
  | DeleteSelectedIntervals
  | SetColor(colorScheme)
  | SetCurrentIds(id, intervalGroupId)
  | SetCurrentGroupId(option<intervalGroupId>)
  | SetRepeater(float)
  | SelectRepeater(intervalGroupId)
  | SelectInterval(intervalId)
  | SetIntervalName(name)
  | SetRangeSelector(rangeSelector)
  | SetScrollPosition(float)
  | SetTimerName(name)
  | InitTimer(timer)
  | UnselectRepeater(intervalGroupId)
  | UnselectInterval(intervalId)
  | None

let reducer = (state: state, action: action) => {
  switch action {
  | SetRangeSelector(rangeSelector) => {
      ...state,
      rangeSelector,
    }
  | InitTimer(timer) => {
      ...state,
      changedId: None,
      isDirty: false,
      timer: getTimerFromPlayList(~timer),
    }
  | CreateTimer(timerType, userId) => {
      ...state,
      rangeSelector: Types.TimerType(timerType),
      timer: {
        ...initialState.timer,
        delayBetweenIntervals: 0.0,
        totalElapsedTime: 0.0,
        currentIntervalIndex: 0,
        currentIntervalGroupIndex: 0,
        isMuted: false,
        prevNow: Js.Date.now(),
        name: "",
        _rev: None,
        status: #NotStarted,
        updatedAt: 0.0,
        intervalGroups: [],
        createdAt: Js.Date.getTime(Js.Date.make()),
        userId,
        id: Uuid.V4.make(),
        timerType,
      },
    }
  | SetTimerName(name) => {
      ...state,
      isDirty: false,
      timer: {
        ...state.timer,
        name,
      },
    }
  | SetIntervalName(name) =>
    switch state.currentIds {
    | Some(_currentIds) => {
        let (intervalId, intervalGroupId) = _currentIds

        let newIntervalGroups = state.timer.intervalGroups
        let currentIntervalGroupIndex = TimerUtils.getIntervalGroupIndexById(
          ~intervalGroupId,
          ~timer=state.timer,
        )
        let newIntervalGroup = newIntervalGroups[currentIntervalGroupIndex]
        let newIntervals = newIntervalGroup.intervals

        let intervalIndex = Js.Array2.findIndex(newIntervals, interval => {
          interval.id === intervalId
        })

        newIntervals[intervalIndex] = {
          ...newIntervals[intervalIndex],
          name,
        }

        newIntervalGroups[currentIntervalGroupIndex] = {
          ...newIntervalGroups[currentIntervalGroupIndex],
          intervals: newIntervals,
        }

        {
          ...state,
          changedId: Some(intervalId),
          timer: {
            ...state.timer,
            intervalGroups: newIntervalGroups,
          },
        }
      }

    | None => state
    }

  | SelectRepeater(intervalGroupId) => {
      ...state,
      selectedRepeaterIntervalGroupIds: Belt.Array.concat(
        state.selectedRepeaterIntervalGroupIds,
        [intervalGroupId],
      ),
    }
  | UnselectRepeater(intervalGroupId) => {
      ...state,
      selectedRepeaterIntervalGroupIds: state.selectedRepeaterIntervalGroupIds->filter(
        _intervalGroupId => {
          intervalGroupId !== _intervalGroupId
        },
      ),
    }
  | SelectInterval(intervalId) => {
      ...state,
      selectedIntervalIds: Belt.Array.concat(state.selectedIntervalIds, [intervalId]),
    }
  | UnselectInterval(intervalId) => {
      ...state,
      selectedIntervalIds: state.selectedIntervalIds->filter(_intervalId => {
        intervalId !== _intervalId
      }),
    }
  | DeleteSelectedIntervals => {
      let updatedIntervalGroups = Belt.Array.map(state.timer.intervalGroups, intervalGroup => {
        let intervals = Belt.Array.keep(intervalGroup.intervals, interval => {
          !Belt.Array.some(state.selectedIntervalIds, id => id === interval.id)
        })

        {
          ...intervalGroup,
          intervals,
        }
      })

      let updatedIntervalGroups =
        updatedIntervalGroups->Belt.Array.keep(intervalGroup =>
          Belt.Array.length(intervalGroup.intervals) > 0
        )

      {
        ...state,
        changedId: None,
        isDirty: true,
        timer: {
          ...state.timer,
          intervalGroups: updatedIntervalGroups,
        },
      }
    }

  | SetColor(color) =>
    switch state.currentIds {
    | Some(_currentIds) => {
        let (intervalId, intervalGroupId) = _currentIds

        let newIntervalGroups = state.timer.intervalGroups
        let currentIntervalGroupIndex = TimerUtils.getIntervalGroupIndexById(
          ~intervalGroupId,
          ~timer=state.timer,
        )
        let newIntervalGroup = newIntervalGroups[currentIntervalGroupIndex]

        let newIntervals = newIntervalGroup.intervals

        let intervalIndex = Js.Array2.findIndex(newIntervals, interval => {
          interval.id === intervalId
        })

        newIntervals[intervalIndex] = {
          ...newIntervals[intervalIndex],
          colorScheme: color,
        }

        newIntervalGroups[currentIntervalGroupIndex] = {
          ...newIntervalGroups[currentIntervalGroupIndex],
          intervals: newIntervals,
        }

        {
          ...state,
          changedId: Some(intervalId),
          isDirty: true,
          timer: {
            ...state.timer,
            intervalGroups: newIntervalGroups,
          },
        }
      }

    | None => state
    }

  | SetScrollPosition(position) => {
      ...state,
      scrollTo: position,
    }

  | SetCurrentGroupId(intervalGroupId) =>
    switch intervalGroupId {
    | Some(intervalGroupId) => {
        ...state,
        changedId: None,
        currentIds: Some("", intervalGroupId),
      }
    | None =>
      switch Belt.Array.length(state.timer.intervalGroups) > 0 {
      | true => {
          let id = state.timer.intervalGroups[Belt.Array.length(state.timer.intervalGroups) - 1].id
          {
            ...state,
            changedId: None,
            currentIds: Some("", id),
          }
        }

      | false => 
        state
      }
    }

  | SetCurrentIds(id, intervalGroupId) => {
      ...state,
      changedId: None,
      currentIds: Some(id, intervalGroupId),
    }
  | SetIntervalTime(time) =>
    switch state.currentIds {
    | Some(_currentIds) => {
        let (intervalId, intervalGroupId) = _currentIds

        let newIntervalGroups = state.timer.intervalGroups
        let currentIntervalGroupIndex = TimerUtils.getIntervalGroupIndexById(
          ~intervalGroupId,
          ~timer=state.timer,
        )
        let newIntervalGroup = newIntervalGroups[currentIntervalGroupIndex]

        let newIntervals = newIntervalGroup.intervals

        let intervalIndex = Js.Array2.findIndex(newIntervals, interval => {
          interval.id === intervalId
        })

        newIntervals[intervalIndex] = {
          ...newIntervals[intervalIndex],
          totalTime: time,
        }

        newIntervalGroups[currentIntervalGroupIndex] = {
          ...newIntervalGroups[currentIntervalGroupIndex],
          intervals: newIntervals,
        }

        {
          ...state,
          changedId: Some(intervalId),
          isDirty: true,
          timer: {
            ...state.timer,
            intervalGroups: newIntervalGroups,
          },
        }
      }

    | None => state
    }

  | CreateRepeater => {
      let lastIntervalGroup =
        state.timer.intervalGroups[Belt.Array.size(state.timer.intervalGroups) - 1]

      let lastIntervalOfGroup =
        lastIntervalGroup.intervals[Belt.Array.size(lastIntervalGroup.intervals) - 1]

      {
        ...state,
        currentIds: Some(lastIntervalOfGroup.id, lastIntervalGroup.id),
        scrollTo: 1.7976931348623157e+308,
        rangeSelector: Repeater,
      }
    }

  | CreateInterval =>
    let newIntervalId = Uuid.V4.make()
    let newIntervalGroupId = Uuid.V4.make()
    let defaultInterval = {
      colorScheme: #Blue,
      elapsedTime: 0.0,
      endTime: 0.0,
      name: "",
      totalTime: 0.0,
      id: newIntervalId,
    }

    let defaultIntervalGroup = {
      id: newIntervalGroupId,
      intervals: [],
      repeatCount: 0.0,
    }

    let numberOfIntervalGroups = Belt.Array.size(state.timer.intervalGroups)

    if numberOfIntervalGroups > 0 {
      let newIntervalGroup = state.timer.intervalGroups[numberOfIntervalGroups - 1]

      switch newIntervalGroup.repeatCount > 0.0 {
      | true =>
        let _newIntervalGroup = {
          ...defaultIntervalGroup,
          intervals: [defaultInterval],
        }

        let _newIntervalGroups = Js.Array2.concat(state.timer.intervalGroups, [_newIntervalGroup])
        {
          ...state,
          isDirty: true,
          currentIds: Some(newIntervalId, newIntervalGroupId),
          scrollTo: MAX_NUMBER_VALUE,
          rangeSelector: TimerType(state.timer.timerType),
          timer: {
            ...state.timer,
            intervalGroups: _newIntervalGroups,
          },
        }
      | false =>
        let intervalGroupIndex = numberOfIntervalGroups - 1

        let newIntervals = Js.Array2.concat(newIntervalGroup.intervals, [defaultInterval])

        let newIntervalGroups = state.timer.intervalGroups

        newIntervalGroups[intervalGroupIndex] = {
          ...newIntervalGroup,
          intervals: newIntervals,
        }

        {
          ...state,
          isDirty: true,
          currentIds: Some(newIntervalId, newIntervalGroups[intervalGroupIndex].id),
          rangeSelector: TimerType(state.timer.timerType),
          scrollTo: MAX_NUMBER_VALUE, 
          timer: {
            ...state.timer,
            intervalGroups: newIntervalGroups,
          },
        }
      }
    } else {
      {
        ...state,
        isDirty: true,
        currentIds: Some(newIntervalId, newIntervalGroupId),
        rangeSelector: TimerType(state.timer.timerType),
        scrollTo: MAX_NUMBER_VALUE, 
        timer: {
          ...state.timer,
          intervalGroups: [
            {
              ...defaultIntervalGroup,
              intervals: [defaultInterval],
            },
          ],
        },
      }
    }

  | SetRepeater(count) =>
    switch state.currentIds {
    | Some(_currentIds) => {
        let (intervalId, intervalGroupId) = _currentIds

        let newIntervalGroup = TimerUtils.getIntervalGroupById(~intervalGroupId, ~timer=state.timer)
        let intervalGroupIndex = TimerUtils.getIntervalGroupIndexById(
          ~intervalGroupId,
          ~timer=state.timer,
        )

        let timer = state.timer

        let _newIntervalGroup = {
          ...newIntervalGroup,
          repeatCount: count,
        }

        let newIntervalGroups = timer.intervalGroups

        newIntervalGroups[intervalGroupIndex] = {
          ...newIntervalGroup,
          repeatCount: count,
        }

        {
          ...state,
          changedId: Some(intervalGroupId),
          isDirty: true,
          timer: {
            ...state.timer,
            intervalGroups: newIntervalGroups,
          },
        }
      }

    | None => state
    }
  | None => state
  }
}
