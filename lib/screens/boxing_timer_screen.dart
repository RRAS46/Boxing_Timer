import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/providers/audio_provider.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';
import 'package:boxing_timer_v1/providers/settings_provider.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:boxing_timer_v1/themes.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';




FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


class BoxingTimerPage extends StatefulWidget {
  @override
  _BoxingTimerPageState createState() => _BoxingTimerPageState();
}

class _BoxingTimerPageState extends State<BoxingTimerPage> {
  int _currentRound = 1;
  int _timeLeft = 180; // Placeholder for initial round time
  int _preparationTime = 10; // Preparation time of 10 seconds
  int current_time_to_total=0;
  int _time_of_current_state=180;
  bool _isBreak = false;
  bool _isRunning = false;
  bool _isPreparation = true; // Indicates if we're in preparation time
  bool workout_done=false;
  bool notificationButtonPausePressed=false;
  Timer? _timer;


  final AudioPlayer _audioPlayer = AudioPlayer();



  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<ProfileProvider>(context,listen: false);
    final setupProvider = Provider.of<SetupProvider>(context,listen: false);
    _preparationTime=setupProvider.program.preparationDuration;
    _timeLeft = _preparationTime; // Start with preparation time
    _time_of_current_state=_preparationTime;
    workout_done=false;
    _startTimer(); // Start the timer immediately
    _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.sonification,  // For short sound effects
          usageType: AndroidUsageType.media,      // Notification-like usage
          audioFocus: AndroidAudioFocus.none,            // No audio focus to avoid pausing background music
        ),
      ),
    );
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);


  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    AwesomeNotifications().dismiss(20);
    super.dispose();
  }




  // Set Audio Context to avoid interrupting background music
  Future<void> _playSound(String fileName) async {
    // Configure the audio context to mix the sound with other audio sources.


    // Play the sound
    await _audioPlayer.play(AssetSource('sounds/$fileName'));
  }
  Future<bool> checkVibrator() async {
    bool? temp=await Vibration.hasVibrator();
    return temp??false;
  }
  void checkAndVibrate(SettingsProvider settingsProvider) async {
    bool temp = await checkVibrator();
    if (temp && settingsProvider.vibrationAlertEnabled) {
      Vibration.vibrate(); // Vibrates if conditions are met
    }
  }

  void updateCountdownNotification(int remainingSeconds,int currentRound) async{
    // Format the remaining time into minutes and seconds
    String minutesStr = ((remainingSeconds ~/ 60) % 60).toString().padLeft(2, '0');
    String secondsStr = (remainingSeconds % 60).toString().padLeft(2, '0');
    String countdownTime = '$minutesStr:$secondsStr';


    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 20, // Unique ID for the countdown notification
        channelKey: 'boxing_timer_channel',
        title: 'Boxing Timer',
        body: 'Time remaining: $countdownTime',

        notificationLayout: NotificationLayout.Default,
        autoDismissible: !_isRunning, // Prevent the user from dismissing the notification
        displayOnForeground: false, // Display even when the app is in foreground
        displayOnBackground: true, // Display on the lock screen and background
        criticalAlert: false,
        playState: NotificationPlayState.playing,
        customSound: "",
        icon:     'resource://mipmap/boxing_timer_logo_gradient', // app icon
        locked: _isRunning, // Make it an ongoing notification
        wakeUpScreen: false,


      ),
      actionButtons: [
        NotificationActionButton(
          key: 'PAUSE',
          label: notificationButtonPausePressed ? 'Play' : 'Pause',

        ),
        NotificationActionButton(
          key: 'CLOSE',
          label: 'Close',
        ),
      ],

    );
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) async =>  onActionReceived(receivedAction),
      onDismissActionReceivedMethod: (receivedAction) async=> onDismissActionReceived(receivedAction),
      onNotificationCreatedMethod: (receivedNotification) async=> onNotificationCreated(receivedNotification),
      onNotificationDisplayedMethod: (receivedNotification) async=> onNotificationDisplayed(receivedNotification),
    );

  }

  // Static method to handle actions when the app is in the background
  @pragma('vm:entry-point')
  void onActionReceived(ReceivedAction receivedAction) {
    // Handle the action when a notification is tapped
    if (receivedAction.buttonKeyPressed != null) {
      if (receivedAction.buttonKeyPressed == 'PAUSE') {
        // Navigate to a specific screen or perform an action
        setState(() {
          notificationButtonPausePressed=true;
          _pauseTimer();
        });
        print('View button pressed. Payload: ${receivedAction.payload}');
        // Note: You cannot navigate from here since it's in the background
      } else if (receivedAction.buttonKeyPressed == 'CLOSE') {

        print('Close button pressed.');
      }
    }

    // Handle the notification payload if any
    if (receivedAction.payload != null) {
      print('Notification payload: ${receivedAction.payload}');
    }
  }

  void onNotificationCreated(ReceivedNotification receivedNotification) {
    print('Notification created: ${receivedNotification.title}');
  }

  void onNotificationDisplayed(ReceivedNotification receivedNotification) {
    print('Notification displayed: ${receivedNotification.title}');
  }

  void onDismissActionReceived(ReceivedAction receivedAction) {
    print('Notification dismissed: ${receivedAction.payload}');
  }


  // Show a notification when the timer ends
  void sendBoxingNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'boxing_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  void _startTimer() {
    final setupProvider = Provider.of<SetupProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    if (!_isRunning && !workout_done) {
      _isRunning = true;

      // Uncomment the following lines if sound is needed at the start of preparation
      // if (_isPreparation && settingsProvider.soundEnabled) {
      //   _playSound('boxing_bell_sound.mp3'); // Play sound at the start of preparation
      // }

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_timeLeft > 1) {

            _timeLeft--;
            current_time_to_total++;

            if(_timeLeft<=3 ){
              if (settingsProvider.soundEnabled && settingsProvider.threeSecondWarningEnabled) {
                _playSound('Beep.mp3'); // Play sound at the start of the first round
              }
            }


            updateCountdownNotification(_timeLeft,_currentRound);
          } else {
            current_time_to_total++;

            if (_isPreparation) {
              // When preparation time ends, start the first round
              _isPreparation = false;
              _isBreak = false;
              _currentRound = 1;
              _timeLeft = setupProvider.program.workDuration;
              _time_of_current_state = setupProvider.program.workDuration;

              if (settingsProvider.soundEnabled) {
                _playSound(settingsProvider.selectedRoundSound.path); // Play sound at the start of the first round
              }
              checkAndVibrate(settingsProvider);

            } else if (_isBreak) {
              if (_currentRound < setupProvider.program.rounds) {
                _isBreak = false;
                _currentRound++;
                _timeLeft = setupProvider.program.workDuration; // Reset work duration for the next round
                _time_of_current_state = setupProvider.program.workDuration;

                if(!workout_done){
                  if (settingsProvider.soundEnabled) {
                    _playSound(settingsProvider.selectedBreakSound.path);
                  }

                  checkAndVibrate(settingsProvider);
                }
              } else {
                sendBoxingNotification('Time’s up!', 'The boxing round is finished.');
                workout_done = true; // Mark workout as done

              }
            } else {
              // Logic for handling breaks
              if (_currentRound < setupProvider.program.rounds) {
                _isBreak = true;
                _timeLeft = setupProvider.program.restDuration; // Set rest duration
                _time_of_current_state = setupProvider.program.restDuration;

                if (settingsProvider.soundEnabled) {
                  _playSound(settingsProvider.selectedRoundSound.path); // Sound at the start of the break
                }

                checkAndVibrate(settingsProvider);
              } else {
                // Finalize workout once all rounds and breaks are done

                if(!workout_done){
                  if (settingsProvider.soundEnabled) {
                    _playSound(settingsProvider.selectedRoundSound.path);
                  }

                  checkAndVibrate(settingsProvider);
                }

                workout_done = true; // Mark workout as done
              }

            }
          }
        });
      });
    }
  }



  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    }
    setState(() {});
  }

  void _resetTimer() {
    final setupProvider = Provider.of<SetupProvider>(context, listen: false);
    _timer?.cancel();
    setState(() {

      _isRunning = false;
      _isBreak = true;
      _isPreparation = true; // Reset to preparation mode
      _currentRound = 1;
      _timeLeft = _preparationTime; // Reset to preparation time
      _time_of_current_state=_preparationTime;
      current_time_to_total=0;
    });
  }

  String _formatTime(int seconds, bool checkNumberCount) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    print("------------------------------$seconds----------------------------------");
    String tempString = "";

    if (checkNumberCount) {
      if (seconds < 60) {
        // Less than a minute, show only seconds
        tempString = '$secs';
      } else if (seconds < 3600) {
        // Less than an hour, show minutes and seconds
        tempString = '$minutes:$secs';
      } else {
        // More than an hour, show hours, minutes, and seconds
        tempString = '$hours:$minutes:$secs';
      }
    } else {
      // Always show hours, minutes, and seconds
      tempString = '$hours:$minutes:$secs';
    }

    return tempString;
  }


  int calculateTotalDuration(Program program) {
    int totalTime = 0;

    // Add preparation time
    totalTime += program.preparationDuration;

    // Iterate through all rounds and sum up round times and break times
    print(program.rounds);
    totalTime += (program.workDuration * program.rounds);
    totalTime += (program.restDuration * (program.rounds-1));

    return totalTime;
  }

  @override
  Widget build(BuildContext context) {
    final setupProvider = Provider.of<SetupProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = orientation == Orientation.portrait;
    isPortrait ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]):
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    bool isLightMode = Theme.of(context).brightness == Brightness.light;


    return isPortrait
        ? Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPreparation
                ? isLightMode ? colorBoxingTimerScreenPreparationModeBackgroundLight : colorBoxingTimerScreenPreparationModeBackgroundDark
                : _isBreak ? isLightMode ? colorBoxingTimerScreenBreakModeBackgroundLight : colorBoxingTimerScreenBreakModeBackgroundDark : isLightMode ? colorBoxingTimerScreenRoundModeBackgroundLight : colorBoxingTimerScreenRoundModeBackgroundDark,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: workout_done
            ? _buildEndScreenPortrait(screenSize)
            : Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenSize.height* getResponsiveValueGeneral(context: context, mobileDevices: 0.05, tablets: 0.01, laptops: 0.01, desktops: 0.01, tv: 0.01),
              ),
              Text(
                _isPreparation
                    ? "Preparation Time"
                    : _isBreak
                    ? 'Break Time'
                    : 'Box Time',
                style: TextStyle(
                    fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 22.0, tablets: 30.0, laptops: 30.0, desktops: 30.0, tv: 30.0),
                    fontWeight: FontWeight.w600,
                    color: isLightMode ? colorBoxingTimerScreenTitleLight : colorBoxingTimerScreenTitleDark
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLightMode ? colorBoxingTimerScreenCardBackgroundLight : colorBoxingTimerScreenCardBackgroundDark,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Round $_currentRound',
                      style: TextStyle(
                        fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 50.0, tablets: 60.0, laptops: 50.0, desktops: 50.0, tv: 50.0),
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? colorBoxingTimerScreenCardTitleLight : colorBoxingTimerScreenCardTitleDark,
                      ),
                    ),
                    Text(
                      'Out of ${setupProvider.program.rounds}',
                      style: TextStyle(
                        fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 24.0, tablets: 24.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? colorBoxingTimerScreenCardTitleLight : colorBoxingTimerScreenCardTitleDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenSize.height* getResponsiveValueGeneral(context: context, mobileDevices: 0.02, tablets: 0.05, laptops: 0.05, desktops: 0.05, tv: 0.05),
              ),
              Expanded( // Use Expanded to allow flexibility
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The circular progress bar
                    SizedBox(
                      width: screenSize.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.75, tablets: 0.7, laptops: 0.7, desktops: 0.7, tv: 0.7),
                      height: screenSize.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.75, tablets: 0.7, laptops: 0.7, desktops: 0.7, tv: 0.7),
                      child: CircularProgressIndicator(
                        value: 1 - (_timeLeft / _time_of_current_state), // Progress of the circular bar (0.0 to 1.0)
                        strokeWidth: 25.0,
                        backgroundColor: isLightMode ? colorBoxingTimerScreenCircularProgressIndicatorBackgroundLight : colorBoxingTimerScreenCircularProgressIndicatorBackgroundDark,
                        valueColor:  AlwaysStoppedAnimation<Color>(isLightMode ? colorBoxingTimerScreenCircularProgressIndicatorForegroundLight : colorBoxingTimerScreenCircularProgressIndicatorForegroundDark),
                        strokeAlign: 2,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Countdown text inside the progress indicator
                    Text(
                      '${_formatTime(_timeLeft, true)}', // Display the current count
                      style: TextStyle(
                          fontSize: _timeLeft < 60
                              ? screenSize.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.6, tablets: 0.55, laptops: 0.6, desktops: 0.6, tv: 0.6)
                              : screenSize.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.3, tablets: 0.26, laptops: 0.3, desktops: 0.3, tv: 0.3),
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? colorBoxingTimerScreenCircularProgressIndicatorTextLight : colorBoxingTimerScreenCircularProgressIndicatorTextDark),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.01, tablets: 0.01, laptops: 0.01, desktops: 0.01, tv: 0.01)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    child: Container(
                        margin: EdgeInsets.all(6),
                        child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 40,)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0)),
                      textStyle: TextStyle(fontSize: 20),
                      backgroundColor: isLightMode ? colorBoxingTimerScreenButtonBackgroundLight : colorBoxingTimerScreenButtonBackgroundDark,
                      foregroundColor: isLightMode ? colorBoxingTimerScreenButtonTextLight : colorBoxingTimerScreenButtonTextDark,
                      shape: CircleBorder(),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        "${_formatTime((calculateTotalDuration(setupProvider.program) - current_time_to_total), true)}",
                        style: TextStyle(
                          fontSize: (calculateTotalDuration(setupProvider.program) - current_time_to_total) >= 3600 ? getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0) : getResponsiveValueGeneral(context: context, mobileDevices: 30.0, tablets: 35.0, laptops: 35.0, desktops: 35.0, tv: 35.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0)),
                      textStyle: TextStyle(fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0)),
                      backgroundColor: isLightMode ? colorBoxingTimerScreenButtonBackgroundLight : colorBoxingTimerScreenButtonBackgroundDark,
                      foregroundColor: isLightMode ? colorBoxingTimerScreenButtonTextLight : colorBoxingTimerScreenButtonTextDark,
                      shape: CircleBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        : Scaffold(
      body: Container(
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPreparation
                ? isLightMode ? colorBoxingTimerScreenPreparationModeBackgroundLight : colorBoxingTimerScreenPreparationModeBackgroundDark
                : _isBreak ? isLightMode ? colorBoxingTimerScreenBreakModeBackgroundLight : colorBoxingTimerScreenBreakModeBackgroundDark : isLightMode ? colorBoxingTimerScreenRoundModeBackgroundLight : colorBoxingTimerScreenRoundModeBackgroundDark,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: workout_done
            ? _buildEndScreenLandscape(screenSize)
            : _buildWorkoutScreen(setupProvider, screenSize, orientation,isLightMode),
      ),
    );
  }

  Widget _buildTitle(Size screenSize,bool isLightMode) {
    return Text(
      _isPreparation ? "Preparation Time" : _isBreak ? 'Break Time' : 'Box Time',
      style: TextStyle(
          fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 22.0, tablets: 32.0, laptops: 32.0, desktops: 32.0, tv: 32.0),
          fontWeight: FontWeight.w600,
          color:  isLightMode ? colorBoxingTimerScreenTitleLight : colorBoxingTimerScreenTitleDark
      ),
    );
  }

  Widget _buildEndScreenPortrait(Size screenSize){
    return Center(
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(25)),
          backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.3)),
        ),
        onPressed: () {
          _resetTimer();
          Navigator.pop(context);
        },
        child: Text(
          "END",
          style: TextStyle(
              fontSize: screenSize.width*.4,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
  Widget _buildEndScreenLandscape(Size screenSize) {
    return Center(
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(25)),
          backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.3)),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "END",
          style: TextStyle(
              fontSize: screenSize.height*.4,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutScreen(SetupProvider setupProvider, Size screenSize, Orientation orientation,bool isLightMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: screenSize.height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: screenSize.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.45, tablets: 0.45, laptops: 0.7, desktops: 0.7, tv: 0.7),
              child: _buildLeftPanel(setupProvider, screenSize,isLightMode)
          ),
          _buildRightPanel(setupProvider, orientation,screenSize,isLightMode),
        ],
      ),
    );
  }
  Widget _buildRoundInfo(SetupProvider setupProvider,bool isLightMode) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLightMode ? colorBoxingTimerScreenCardBackgroundLight : colorBoxingTimerScreenCardBackgroundDark,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Round $_currentRound',
            style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: isLightMode ? colorBoxingTimerScreenCardTitleLight : colorBoxingTimerScreenCardTitleDark),
          ),
          Text(
            'Out of ${setupProvider.program.rounds}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:  isLightMode ? colorBoxingTimerScreenCardTitleLight : colorBoxingTimerScreenCardTitleDark),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(SetupProvider setupProvider,bool isLightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            margin: EdgeInsets.all(6),
            child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: getResponsiveValueGeneral(context: context, mobileDevices: 40.0, tablets: 45.0, laptops: 25.0, desktops: 25.0, tv: 25.0)),
          ),
          style: _buildButtonStyle(isLightMode),
        ),

        SizedBox(width: MediaQuery.of(context).size.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.06, tablets: 0.1, laptops: 0.1, desktops: 0.1, tv: 0.1)), // Spacer between buttons
        ElevatedButton(
          onPressed: () {

          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: Text(
              "${_formatTime((calculateTotalDuration(setupProvider.program) - current_time_to_total), true)}",
              style: TextStyle(fontSize: (calculateTotalDuration(setupProvider.program) - current_time_to_total) >=3600 ? getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0) : getResponsiveValueGeneral(context: context, mobileDevices: 30.0, tablets: 35.0, laptops: 35.0, desktops: 35.0, tv: 35.0), fontWeight: FontWeight.w600),
            ),
          ),
          style: _buildButtonStyle(isLightMode),
        ),
      ],
    );
  }
  ButtonStyle _buildButtonStyle(bool isLightMode) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.all(getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0)),
      textStyle: TextStyle(fontSize: 20),
      backgroundColor:  isLightMode ? colorBoxingTimerScreenButtonBackgroundLight : colorBoxingTimerScreenButtonBackgroundDark,
      foregroundColor:  isLightMode ? colorBoxingTimerScreenButtonTextLight : colorBoxingTimerScreenButtonTextDark,
      shape: CircleBorder(),
    );
  }

  double calculateFontSizeByTime(int time){
    Size screenSize=MediaQuery.of(context).size;
    if(time<60){
      return (screenSize.height * .6);
    }else if(time>=60 && time <3600){
      return (screenSize.height * .3);
    }else {
      return (screenSize.height * 2);
    }
  }
  Widget _buildCircularTimer(Size screenSize,SetupProvider setupProvider,bool isLightMode) {
    return Container(
      height: screenSize.height ,
      alignment: Alignment.center,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: screenSize.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.8, tablets: 0.75, laptops: 0.7, desktops: 0.7, tv: 0.7),
              height: screenSize.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.8, tablets: 0.75, laptops: 0.7, desktops: 0.7, tv: 0.7),
              child: CircularProgressIndicator(
                value: 1 - (_timeLeft / _time_of_current_state),
                strokeWidth: 25.0,
                backgroundColor: isLightMode ? colorBoxingTimerScreenCircularProgressIndicatorBackgroundLight : colorBoxingTimerScreenCircularProgressIndicatorBackgroundDark,
                valueColor: AlwaysStoppedAnimation<Color>(isLightMode ? colorBoxingTimerScreenCircularProgressIndicatorForegroundLight : colorBoxingTimerScreenCircularProgressIndicatorForegroundDark),
                strokeAlign: 1,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${_formatTime(_timeLeft, true)}',
              style: TextStyle(
                fontSize: screenSize.height * (((_timeLeft) >=60 )? getResponsiveValueGeneral(context: context, mobileDevices: 0.3, tablets: 0.28, laptops: 0.3, desktops: 0.3, tv: 0.3) : getResponsiveValueGeneral(context: context, mobileDevices: 0.6, tablets: 0.58, laptops: 0.6, desktops: 0.6, tv: 0.6)),
                fontWeight: FontWeight.bold,
                color: isLightMode ? colorBoxingTimerScreenCircularProgressIndicatorTextLight : colorBoxingTimerScreenCircularProgressIndicatorTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLeftPanel(SetupProvider setupProvider, Size screenSize,bool isLightMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTitle(screenSize,isLightMode),
        SizedBox(height: screenSize.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.01, tablets: 0.02, laptops: 0.02, desktops: 0.02, tv: 0.02)),
        _buildRoundInfo(setupProvider,isLightMode),
        Spacer(),
        _buildControlButtons(setupProvider,isLightMode),

      ],
    );
  }

  Widget _buildRightPanel(SetupProvider setupProvider, Orientation orientation, Size screenSize,bool isLightMode) {
    return Expanded(
      flex: 1,
      child: _buildCircularTimer(screenSize,setupProvider,isLightMode),
    );
  }


}
