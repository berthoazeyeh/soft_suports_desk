import 'package:flutter/widgets.dart';

class MyLoaderBuilder extends StatefulWidget {
  final Future Function() process;
  final void Function() onEnd;
  final Widget Function(BuildContext, VoidCallback runProcess)
      normalStateBuilder;
  final Widget Function(BuildContext) loadingStateBuilder;

  const MyLoaderBuilder({super.key, 
    required this.process,
    required this.onEnd,
    required this.normalStateBuilder,
    required this.loadingStateBuilder,
  });

  @override
  State<StatefulWidget> createState() => _MyLoaderBuilderState();
}

class _MyLoaderBuilderState extends State<MyLoaderBuilder> {
  bool isLoading = false;

  void _process() async {
    setState(() => isLoading = true);
    await widget.process();
    setState(() => isLoading = false);
    widget.onEnd();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return widget.loadingStateBuilder(context);
    } else {
      return widget.normalStateBuilder(context, _process);
    }
  }
}
