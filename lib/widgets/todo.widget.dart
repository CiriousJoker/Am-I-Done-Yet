import 'package:amidoneyet/config/colors.config.dart';
import 'package:amidoneyet/config/general.config.dart';
import 'package:amidoneyet/helper/db.helper.dart';
import 'package:amidoneyet/helper/ui.helper.dart';
import 'package:amidoneyet/models/todo.model.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TodoWidget extends StatefulWidget {
  const TodoWidget({
    Key key,
    @required this.todo,
  }) : super(key: key);

  final TodoModel todo;

  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  double _percent = 0;

  @override
  void initState() {
    super.initState();
    _percent = widget.todo.priority;
    assert(widget.todo != null);
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.todo.title ?? "";

    return Container(
      height: GeneralConfig.todoHeight,
      margin: EdgeInsets.symmetric(
        horizontal: UIHelper.HorizontalSpaceMedium,
        vertical: UIHelper.VerticalSpaceSmall,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.all(Radius.circular(GeneralConfig.todoBorderRadius)),
        child: LayoutBuilder(builder: (ct, c) {
          return Stack(children: [
            LinearPercentIndicator(
              linearStrokeCap: LinearStrokeCap.butt,
              padding: EdgeInsets.all(0),
              lineHeight: c.maxHeight,
              percent: _percent,
              backgroundColor: ColorsConfig.primaryLightened,
              progressColor: ColorsConfig.accent,
            ),
            ListTile(
              title: Text(
                title,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (d) {
                if (!mounted) return;
                setState(() {
                  _percent += d.delta.dx / c.maxWidth;
                  if (_percent > 1) _percent = 1;
                  if (_percent < 0) _percent = 0;
                });
              },
              onHorizontalDragEnd: (d) async {
                assert(widget.todo.timestamp != null);
                db.update(
                  TodoModel(
                    id: widget.todo.id,
                    title: widget.todo.title,
                    priority: _percent,
                    pinned: false,
                    timestamp: widget.todo.timestamp ?? DateTime.now(),
                  ),
                );
              },
              onLongPress: () {
                db.delete(widget.todo.id);
              },
            ),
          ]);
        }),
      ),
    );
  }
}
