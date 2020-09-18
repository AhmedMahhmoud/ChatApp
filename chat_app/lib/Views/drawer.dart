import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final Widget child;
  static _MyDrawerState of(BuildContext context) =>
      context.findRootAncestorStateOfType<_MyDrawerState>();

  const MyDrawer({Key key, this.child}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> with SingleTickerProviderStateMixin {
    AnimationController animationController;
 static const Duration toggleDuration = Duration(microseconds: 250);

  static const double maxSlide = 225;
  
  static const double minDragStartEdge = 60;
  
  static const double maxDragStartEdge = maxSlide - 16;
  AnimationController _animationController;

  bool _canDrag = false;
void initState() {
    super.initState();
    //创建AnimationController对象，指定动画时间
    _animationController = AnimationController(
        vsync: this, duration: _MyDrawerState.toggleDuration);
  }

  void close() {
    _animationController.reverse();
  }

  void open() {
    _animationController.forward();
  }

  void toggleDrawer() {
    _animationController.isCompleted ? close() : open();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        //当抽屉打开时，点击返回先关闭抽屉
        if (_animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        //拖动开始执行事件
        onHorizontalDragStart: _onDragStart,
        //拖动过程中更新事件
        onHorizontalDragUpdate: _onDragUpdate,
        //拖动结束时执行事件
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _animationController,
          child: widget.child,
          builder: (context, child) {
            //当前动画执行进度
            double animValue = _animationController.value;
            //根据进度计算child偏移量
            final slideAmout = maxSlide * animValue;
            //根据进度计算child缩放程度，最大缩放到70%
            final contentScale = 1.0 - 0.3 * animValue;
            return Stack(
              children: <Widget>[
                MyDrawer(),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slideAmout)
                    ..scale(contentScale,contentScale),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    //当抽屉打开时，点击child组件，关闭抽屉
                    onTap: _animationController.isCompleted ? close :null,
                    child: widget.child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    //判断拖动是否是打开抽屉
    bool isDragOpenFromLeft = _animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    //判断拖动是否是关闭抽屉
    bool isDragCloseFromRight = _animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;
    _canDrag = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if(_canDrag){
        //根据偏移量得到当前的动画进度
        double delta = details.primaryDelta / maxSlide;
        _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
      //临界值加速度
      double _kMinFlingVelocity = 365.0;
      //如果当前动画在开始时已经结束 或者 已经执行完毕
      if(_animationController.isDismissed || _animationController.isCompleted){
        return;
      }

      if(details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity){
        //如果当前加速度大于临界值，计算得到可见加速度
        double visualVelcoity = details.velocity.pixelsPerSecond.dx /
            MediaQuery.of(context).size.width;
            //fling()函数允许您提供速度(velocity)、力量(force)、position(通过Force对象)
            _animationController.fling(velocity: visualVelcoity);
      }else if(_animationController.value < 0.5){
          //动画执行不到一半，关闭
          close();
      }else{
        //执行大于一半，打开抽屉
        open();
      }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();

  }
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text('消息'),
              leading: Icon(Icons.message),
            ),
            ListTile(
              title: Text('收藏'),
              leading: Icon(Icons.favorite),
            ),
            ListTile(
              title: Text('地图'),
              leading: Icon(Icons.map),
            ),
            ListTile(
              title: Text('我的'),
              leading: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}