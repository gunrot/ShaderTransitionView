### Shader Transition View

This is a small QML plugin which provides an easy way to apply different transitions between two QML views in your Qt/QML application.

To learn more about the project visit [wiki pages](https://github.com/gunrot/ShaderTransitionView/wiki).

 This short video can show some of those transitions.
[![ScreenShot](https://img-fotki.yandex.ru/get/68556/603575.21/0_d2fd4_2407de61_orig)](
https://youtu.be/rS-fmlKRQ3s)

 There is a demo application which shows how *ShaderTransitionView* actually works. The app can be found [here](https://github.com/gunrot/ShaderTransitionViewDemo).


### STView

**STView** is a QML element which provides a stack-based navigation model with different animation effects between two views.

Import statement: ```import ShaderTransitionView 1.0```

Properties:

* *int* **duration** - the property defines how long the animation lasts (milliseconds).
* *int* **depth** - the property defines the number of items currently pushed onto the stack.
* *string* **currentItem** - the property defines the current QML file. If the current view is a QML component it returns a string *ShaderTranstionView::component:N* where *N* is a number of a QML component in the stack.
* *Array* **transitionOptions** - a javascript array to set options for the current transition.
* *string* **transition** - the property defines which shader effect will be applied for the next transition.
* *real* **progress** - it shows the progress of animation. The value changes from 0.0 to 1.0.
* *alias* **easing** - it specifies the easing curve used for the animation.

Methods:

* *void* **push(** *string* qmlfile **)** - it takes a path to a QML file as an argument which represents the next QML view and puts it into the stack. An animation will be applied to change the current view.
* *void* **pushItem(** *QQmlComponent* item **)** - it puts the next view represented as a QML component into the stack. An animation will be applied to change the current view.
* *void* **pop()** - it removes the last view from the stack. An animation will be applied to change the current view.
* *void* **clear()** - it removes all views from the stack.
* *void* **completeTransition()** - It immediately completes any transition.
* *TYPE* **top()** - it returns the stack's top item. If the top element is a path than *TYPE* is a string, otherwise it is *QQmlComponent*.

Signals:
* **animationStarted()** - this signal is emitted when the animation starts.
* **animationCompleted()** - this signal is emitted when the animation finishes.


### Transitions

The transitions are taken from https://github.com/gl-transitions/gl-transitions. The perl script converts the glsl files into qml files, which can be directly used. A qrc including the generated files and a js file having a function returning an array of the transition names is also generated. No manual modification is needed. The demo uses the js function returning the array of names to show the transtions in a listview.

THere are now over 60 transtions available. Most of them have additional parameters, which  you can pass as na array in the  transitionOptions parameter. Look up the option property names in the transiton qml file.

### How to use it

The video above shows that the content of QML pages can be various. It doesn't matter whether a QML page has maps or any interactive element such as Button or ListView for instance or maybe it's just a static picture.
Let's have a look how to use the plugin in QML:

```QML
import QtQuick 2.5
import QtQuick.Window 2.2
import ShaderTransitionView 1.0

Window {
    visible: true
    width: 1000
    height: 600

    STView {
        id: view
        anchors.fill: parent
        duration: 700
        transition: "Wind"
        transitionOptions: { "color": Qt.vector3d(0.0, 0.0, 0.0) }
    }

    Component.onCompleted: {
        specialView.push( "PageExample1.qml" )
    }
}
```
We created a new window and filled it by *STView*. By calling the method *push(...)* in *Component.onCompleted* in such a way *specialView.push( "PageExample1.qml" )* we put a QML page *PageExample1.qml* into the stack so the page *PageExample1.qml* will be displayed when the window appears. Next time when we want to change the current view by the next one, we need to call the same method *push(...)* or we there is one more similar method *pushItem(...)* in *STView* which puts the next view represented as *QQmlComponent*.
Here is another example:

```QML
import QtQuick 2.5
import QtQuick.Window 2.2
import ShaderTransitionView 1.0

Window {
    visible: true
    width: 1000
    height: 600

    Component {
      id: componentPage2
      MyPage2 {
        id: myPage2
        onBackPressed: {
          stView.transitionOptions = { "forward":false }
          stView.pop()
        }
        onNextPressed: {
          stView.transitionOptions = { "forward":true }
          stView.pushItem( componentPage3 )
        }
      }
    }

    Component {
      id: componentPage3
      MyPage3 {
        id: myPage3
        onBackPressed: {
          stView.transitionOptions = { "forward":false }
          stView.pop()
        }
      }
    }

    STView {
        id: stView
        anchors.fill: parent
        duration: 700
        transition: "Wind"
        transitionOptions: { "size": 0.3 }
    }

    Component.onCompleted: {
        stView.push( "PageExample1.qml" )
    }
}
```
Here we have two additional pages *MyPage2{...}* and *MyPage3{...}* represented as QML components. They will be loaded when we call the method *pushItem(...)* If our pages emit signals *backPressed()* and *nextPressed()* we can define handlers and put/remove pages into/from the stack. This example also shows that we can put any different options for transition every time when we put or remove pages.
 For the button "Back" we can change direction of unfolding animation.
```QML
  stView.transitionOptions = { "forward":false }
  stView.pop()
```
The method *pop()* removes the current page from the stack and displays the previous one. If we want to go to the next page we will do very similar actions but instead removing a page from the stack we need to put it into the stack by calling *push(...)* or *pushItem(...)*.
```QML
  stView.transitionOptions = { "forward":true }
  stView.pushItem( componentPage3 )
```
Transitions and options for each transition can be changed during navigation through the stack.


### An experiment

Experimentally I made similar effects with video as a source. On the video below it's possible to see how it works.
[![ScreenShot](https://img-fotki.yandex.ru/get/68556/603575.21/0_d2fd4_2407de61_orig)](https://youtu.be/Sk99oeZu62g)
