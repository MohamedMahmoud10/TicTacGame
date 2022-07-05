import 'package:flutter/material.dart';
import 'package:tic_tac/game_logic.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String activePlyer = 'X';
  String result = '';
  bool gameOver = false;
  int turn = 0;
  bool isSwitched = false;
  Game game = Game();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(children: [
                ...firstBloc(),
                const SizedBox(
                  height: 100,
                ),
                _expandedTable(context),
                ...lastBloc()
              ])
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...firstBloc(),
                        const SizedBox( height: 50,),
                        ...lastBloc(),
                      ],
                    ),
                  ),
                  _expandedTable(context)
                ],
              ),
      ),
    );
  }

  List<Widget> firstBloc() {
    return [
      //control on or two players
      SwitchListTile.adaptive(
          title: Text(
            isSwitched ? 'Turn Of Two Players' : 'Turn On Two Players',
            style: const TextStyle(fontSize: 30),
          ),
          value: isSwitched,
          onChanged: (bool newVal) {
            setState(
              () {
                isSwitched = newVal;
              },
            );
          }),
      const SizedBox(
        height: 30,
      ),
      //Show turn O or X
      Text(
        'it\'s $activePlyer turn'.toUpperCase(),
        style: const TextStyle(fontSize: 50, color: Colors.white),
      ),
    ];
  }

  Expanded _expandedTable(BuildContext context) {
    return Expanded(
        child: GridView.count(
      padding: const EdgeInsets.all(5),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
      children: [
        //Generate List Contains of 9 Square
        ...List.generate(
            9,
            (index) => InkWell(
                  onTap: gameOver ? null : () => _onTap(index),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Text(
                        Player.playerX.contains(index)
                            ? 'X'
                            : Player.playerO.contains(index)
                                ? 'O'
                                : '',
                        style: TextStyle(
                            fontSize: 60,
                            color: Player.playerX.contains(index)
                                ? Colors.blue
                                : Colors.red),
                      ),
                    ),
                  ),
                ))
      ],
    ));
  }

  List<Widget> lastBloc() {
    return [
      FloatingActionButton(
        backgroundColor: Theme.of(context).splashColor,
        onPressed: () => resetGame(),
        child: const Icon(
          Icons.replay_outlined,
        ),
      ),
      //     //Show Result Who Win
      //     Text(
      //       result.toUpperCase(),
      //       style: const TextStyle(fontSize: 50),
      //     ),
      //     //Repeat The Game And Reinitlize All Varibales
      //     // ElevatedButton.icon(
      //     //     onPressed: () {
      //     //       setState(() {
      //     //         Player.playerX = [];
      //     //         Player.playerO = [];
      //     //         activePlyer = 'X';
      //     //         result = '';
      //     //         gameOver = false;
      //     //         turn = 0;
      //     //         isSwitched = false;
      //     //       });
      //     //     },
      //     //     style: ButtonStyle(
      //     //       backgroundColor:
      //     //           MaterialStateProperty.all(Theme.of(context).splashColor),
      //     //       shape: MaterialStateProperty.all(
      //     //         RoundedRectangleBorder(
      //     //           borderRadius: BorderRadius.circular(15),
      //     //         ),
      //     //       ),
      //     //     ),
      //     //     icon: const Icon(Icons.repeat_sharp),
      //     //     label: const Text(
      //     //       'Repeat The Game',
      //     //       style: TextStyle(fontSize: 30),
      //     //     )),
    ];
  }

  //reset game method
  void resetGame() {
    setState(() {
      Player.playerX = [];
      Player.playerO = [];
      activePlyer = 'X';
      result = '';
      gameOver = false;
      turn = 0;
      //isSwitched = false;
    });
  }

  void _onTap(int index) async {
    if ((!Player.playerX.contains(index) ||
        Player.playerX.isEmpty && !Player.playerO.contains(index) ||
        Player.playerO.isEmpty)) {
      game.playGame(index, activePlyer);
      updateState();
    }

    if (!gameOver && !isSwitched && turn != 9) {
      await game.autoPlay(activePlyer);
      updateState();
    }
  }

  void updateState() {
    return setState(() {
      activePlyer = (activePlyer == 'X') ? 'O' : 'X';
      turn++;
      String winnerPlayer = game.checkWinner();

      if (winnerPlayer != '') {
        gameOver = true;
        final AlertDialog alert = alertDialog(
            winnerPlayer,
            (isSwitched
                ? winnerPlayer = '$winnerPlayer is Win'
                : winnerPlayer == 'X'
                    ? 'You Win !'
                    : 'You Lose !'));
        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return alert;
            });
      } else if (!gameOver && turn == 9) {
        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return alertDialog(winnerPlayer, 'Draw ! ');
            });
      }
    });
  }

  AlertDialog alertDialog(String winnerPlayer, String result) {
    return AlertDialog(
      backgroundColor: Theme.of(context).shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        height: 250,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //const SizedBox(height: 10,),
            Text(
              result,
              style: const TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 75,),
            ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).canvasColor)),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop({resetGame()});
                  });
                },
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic),
                ))
          ],
        ),
      ),
    );
  }
}
