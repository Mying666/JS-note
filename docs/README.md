---
sidebarDepth: 3
---

# 你不知道的JavaScript

## 5.4循环和闭包(2020/11/18)
``` js
for (var i=1; i<=5; i++) {
  (function() {
    setTimeout( function timer() {
      console.log( i );
    }, i*1000 );
  })();
}
```
这样不行。但是为什么呢？我们现在显然拥有更多的词法作用域了。的确每个延迟函数都会将 IIFE 在每次迭代中创建的作用域封闭起来。

如果作用域是空的，那么仅仅将它们进行封闭是不够的。仔细看一下，我们的 IIFE 只是一个什么都没有的空作用域。它需要包含一点实质内容才能为我们所用。它需要有自己的变量，用来在每个迭代中储存 i 的值：
``` js
for (var i=1; i<=5; i++) {
  (function() {
    var j = i;
    setTimeout( function timer() {
      console.log( j );
    }, j*1000 );
  })();
}
```
可以对这段代码进行一些改进：
``` js
for (var i=1; i<=5; i++) {
  (function(j) {
    setTimeout( function timer() {
      console.log( j );
    }, j*1000 );
  })( i );
}
```
在迭代内使用 IIFE 会为每个迭代都生成一个新的作用域，使得延迟函数的回调可以将新的作用域封闭在每个迭代内部，每个迭代中都会含有一个具有正确值的变量供我们访问。

### 块级作用域
let 声明，可以用来劫持块作用域，并且在这个块作用域中声明一个变量。

本质上这是将一个块转换成一个可以被关闭的作用域。

``` js
for (let i=1; i<=5; i++) {
  setTimeout( function timer() {
    console.log( i );
  }, i*1000 );
}
```

## 5.5模块

``` js
function CoolModule() {
  var something = "cool";
  var another = [1, 2, 3];

  function doSomething() {
    console.log( something );
  }

  function doAnother() {
    console.log( another.join( " ! " ) );
  }

  return {
    doSomething: doSomething,
    doAnother: doAnother
  };
}

var foo = CoolModule();
foo.doSomething(); // cool
foo.doAnother(); // 1 ! 2 ! 3
```
这个模式在 JavaScript 中被称为模块。最常见的实现模块模式的方法通常被称为模块暴露，这里展示的是其变体。

首先， CoolModule() 只是一个函数，必须要通过调用它来创建一个模块实例。如果不执行外部函数，内部作用域和闭包都无法被创建。

其次， CoolModule() 返回一个用对象字面量语法 { key: value, ... } 来表示的对象。这个返回的对象中含有对内部函数而不是内部数据变量的引用。我们保持内部数据变量是隐藏且私有的状态。可以将这个对象类型的返回值看作本质上是模块的公共 API。

这个对象类型的返回值最终被赋值给外部的变量 foo ，然后就可以通过它来访问 API 中的属性方法，比如 foo.doSomething() 。

doSomething() 和 doAnother() 函数具有涵盖模块实例内部作用域的闭包（通过调用CoolModule() 实现）。当通过返回一个含有属性引用的对象的方式来将函数传递到词法作用域外部时，我们已经创造了可以观察和实践闭包的条件。

::: tip 模块模式需要具备两个必要条件。
1. 必须有外部的封闭函数，该函数必须至少被调用一次（每次调用都会创建一个新的模块实例）。
2. 封闭函数必须返回至少一个内部函数，这样内部函数才能在私有作用域中形成闭包，并且可以访问或者修改私有的状态
:::
::: warning 一个具有函数属性的对象本身并不是真正的模块。
从方便观察的角度看，一个从函数调用所返回的，只有数据属性而没有闭包函数的对象并不是真正的模块。
:::
当只需要一个实例时，可以对这个模式进行简单的改进来实现单例模式：
``` js
var foo = (function CoolModule() {
  var something = "cool";
  var another = [1, 2, 3];

  function doSomething() {
    console.log( something );
  }

  function doAnother() {
    console.log( another.join( " ! " ) );
  }

  return {
    doSomething: doSomething,
    doAnother: doAnother
  };
})();

foo.doSomething(); // cool
foo.doAnother(); // 1 ! 2 ! 3
```
模块模式另一个简单但强大的变化用法是，命名将要作为公共 API 返回的对象：
``` js
var foo = (function CoolModule(id) {
  function change() {
    // 修改公共 API
    publicAPI.identify = identify2;
  }

  function identify1() {
    console.log( id );
  }

  function identify2() {
    console.log( id.toUpperCase() );
  }

  var publicAPI = {
    change: change,
    identify: identify1
  };
  return publicAPI;
})( "foo module" );

foo.identify(); // foo module
foo.change();
foo.identify(); // FOO MODULE
```
通过在模块实例的内部保留对公共 API 对象的内部引用，可以从内部对模块实例进行修改，包括添加或删除方法和属性，以及修改它们的值。

### 现代模块机制

大多数模块依赖加载器 / 管理器本质上都是将这种模块定义封装进一个友好的 API。

``` js{8}
var MyModules = (function Manager() {
  var modules = {};

  function define(name, deps, impl) {
    for (var i = 0; i < deps.length; i++) {
      deps[i] = modules[deps[i]];
    }
    modules[name] = impl.apply(impl, deps);
  }

  function get(name) {
    return modules[name];
  }

  return {
    define: define,
    get: get
  };
})();
```
这段代码的核心是 modules[name] = impl.apply(impl, deps) 。为了模块的定义引入了包装函数（可以传入任何依赖），并且将返回值，也就是模块的 API，储存在一个根据名字来管理的模块列表中。

下面展示了如何使用它来定义模块：

``` js
MyModules.define("bar", [], function () {
  function hello(who) {
    return "Let me introduce: " + who;
  }
  return {
    hello: hello
  };
});

MyModules.define("foo", ["bar"], function (bar) {
  var hungry = "hippo";
  function awesome() {
    console.log(bar.hello(hungry).toUpperCase());
  }
  return {
    awesome: awesome
  };
});

var bar = MyModules.get("bar");
var foo = MyModules.get("foo");

console.log(
  bar.hello("aaa")
); // Let me introduce: aaa

foo.awesome() // LET ME INTRODUCE: HIPPO
```
" foo " 和 "bar" 模块都是通过一个返回公共 API 的函数来定义的。 "foo" 甚至接受 "bar" 的示例作为依赖参数，并能相应地使用它。

::: tip 它们符合前面列出的模块模式的两个特点：
为函数定义引入包装函数，并保证它的返回值和模块的 API 保持一致。
:::

### 5.5.2　未来的模块机制
ES6 中为模块增加了一级语法支持。但通过模块系统进行加载时，ES6 会将文件当作独立的模块来处理。每个模块都可以导入其他模块或特定的 API 成员，同样也可以导出自己的API 成员。

::: tip 相比之下，ES6 模块 API 更加稳定（API 不会在运行时改变）。
由于编辑器知道这一点，因此可以在（的确也这样做了）编译期检查对导入模块的 API 成员的引用是否真实存在。如果 API 引用并不存在，编译器会在运行时抛出一个或多个“早期”错误，而不会像往常一样在运行期采用动态的解决方案。
:::

ES6 的模块没有“行内”格式，必须被定义在独立的文件中（一个文件一个模块）。

::: warning
[module为以前的关键字，现在合并使用import](https://github.com/getify/You-Dont-Know-JS/issues/664)
demo1
下面代码根据最新es6语法稍作修改
:::

bar.js
``` js
export function hello(who) {
  return "Let me introduce: " + who;
}

export default {
  hello
}
```

foo.js
``` js
// 仅从 "bar" 模块导入 hello()
import { hello } from "./bar.js";

var hungry = "hippo";
export function awesome() {
  console.log(
    hello( hungry ).toUpperCase()
  );
}

export default {
  awesome
}
```

baz.js
``` js
// 导入完整的 "foo" 和 "bar" 模块
import foo from "./foo.js";
import bar from "./bar.js";

console.log(
  bar.hello( "rhino" )
); // Let me introduce: rhino

foo.awesome(); // LET ME INTRODUCE: HIPPO
```

index.html
::: tip script标签
type="module"
:::
``` html {11}
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>

<body>
  <script type="module" src="./baz.js"></script>
</body>

</html>
```























