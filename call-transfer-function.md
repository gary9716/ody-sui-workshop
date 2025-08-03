# 使用 Sui CLI 调用 Transfer 函数

## Transfer 函数类型

在 Sui Move 中，有几种不同的 transfer 函数：

### 1. `transfer::transfer()` - 私有 transfer
- 只能由模块内部调用
- 不能通过 Sui CLI 直接调用

### 2. `transfer::public_transfer()` - 公共 transfer
- 可以被外部调用
- 可以通过 Sui CLI 调用

### 3. `transfer::share_object()` - 共享对象
- 将对象设为共享状态
- 可以被外部调用

## 可调用的 Transfer 函数示例

### 示例 1: 从 hello_move 模块

```move
// courses/01_hello/hello_move/sources/hello.move
transfer(hello_move, ctx.sender());
```

这个函数在 `init` 函数内部，不能直接调用。

### 示例 2: 从 lesson_one 模块

```move
// lessons/lesson_1/sources/lesson_one.move
transfer::public_transfer(
    Rookie {
        id: object::new(ctx),
        creator: ctx.sender(),
        name,
        img_url: ascii::string(b""),
        signer: option::none(),
    },
    ctx.sender(),
);
```

这个在 `new_member` 函数中，可以通过调用 `new_member` 来间接使用。

## 直接调用 Transfer 函数

### 方法 1: 调用包含 transfer 的公共函数

```bash
# 调用 new_member 函数（内部包含 transfer）
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function new_member \
  --args "Your Name" \
  --gas-budget 10000000
```

### 方法 2: 调用 share_object 函数

```bash
# 如果模块有 share_object 函数
sui client call \
  --package <PACKAGE_ID> \
  --module <MODULE_NAME> \
  --function share_object \
  --args <OBJECT_ID> \
  --gas-budget 10000000
```

## 实际示例

### 示例 1: 调用 hello_move 的 init 函数

```bash
# 进入项目目录
cd courses/01_hello/hello_move

# 构建并发布
sui move build
sui client publish --gas-budget 10000000

# 调用 init 函数（内部会 transfer 对象）
sui client call \
  --package <PACKAGE_ID> \
  --module hello \
  --function init \
  --gas-budget 10000000
```

### 示例 2: 调用 lesson_one 的 new_member 函数

```bash
# 进入项目目录
cd lessons/lesson_1

# 构建并发布
sui move build
sui client publish --gas-budget 10000000

# 调用 new_member 函数（内部会 transfer Rookie 对象）
sui client call \
  --package <PACKAGE_ID> \
  --module lesson_one \
  --function new_member \
  --args "Alice Smith" \
  --gas-budget 10000000
```

## 创建自定义 Transfer 函数

如果您想创建可以通过 CLI 调用的 transfer 函数，可以这样做：

```move
module my_module::transfer_example {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    public struct MyObject has key, store {
        id: UID,
        value: u64,
    }

    // 可以通过 CLI 调用的 transfer 函数
    public fun transfer_object(obj: MyObject, recipient: address) {
        transfer::public_transfer(obj, recipient);
    }

    // 创建对象的函数
    public fun create_object(value: u64, ctx: &mut TxContext) {
        let obj = MyObject {
            id: object::new(ctx),
            value,
        };
        transfer::public_transfer(obj, ctx.sender());
    }
}
```

然后调用：

```bash
# 调用 transfer_object 函数
sui client call \
  --package <PACKAGE_ID> \
  --module transfer_example \
  --function transfer_object \
  --args <OBJECT_ID> <RECIPIENT_ADDRESS> \
  --gas-budget 10000000
```

## 查找可调用的 Transfer 函数

### 方法 1: 搜索公共函数

```bash
# 在项目中搜索 public fun
grep -r "public fun" . --include="*.move"
```

### 方法 2: 查看模块结构

```bash
# 查看特定模块的所有函数
grep -A 5 -B 5 "public fun" lessons/lesson_1/sources/lesson_one.move
```

## 完整的调用脚本

```bash
#!/bin/bash

echo "=== 调用 Transfer 函数 ==="

# 设置变量
PACKAGE_ID="0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7"
MODULE="lesson_one"
FUNCTION="new_member"

echo "📋 包信息："
echo "- 包 ID: $PACKAGE_ID"
echo "- 模块: $MODULE"
echo "- 函数: $FUNCTION (包含 transfer 操作)"

echo ""
echo "🔍 检查包是否已发布..."
PACKAGE_EXISTS=$(sui client objects --query-type package | grep "$PACKAGE_ID")

if [ -z "$PACKAGE_EXISTS" ]; then
    echo "❌ 包未发布，正在发布包..."
    cd lessons/lesson_1
    sui move build
    sui client publish --gas-budget 10000000
    cd ../..
else
    echo "✅ 包已发布"
fi

echo ""
echo "🔄 调用包含 transfer 的函数..."
read -p "请输入名称: " NAME

if [ -z "$NAME" ]; then
    NAME="Test User"
    echo "使用默认名称: $NAME"
fi

# 调用函数
sui client call \
  --package "$PACKAGE_ID" \
  --module "$MODULE" \
  --function "$FUNCTION" \
  --args "$NAME" \
  --gas-budget 10000000

if [ $? -eq 0 ]; then
    echo "✅ 调用成功！"
    echo ""
    echo "📋 验证结果："
    echo "查看新创建的对象："
    sui client objects --query-type lesson_one::lesson_one::Rookie
else
    echo "❌ 调用失败"
fi
```

## 注意事项

1. **私有函数**：`transfer::transfer()` 是私有函数，不能直接通过 CLI 调用
2. **公共函数**：只有 `public_transfer()` 和 `share_object()` 可以通过 CLI 调用
3. **间接调用**：通过调用包含 transfer 操作的公共函数来间接使用
4. **权限检查**：确保您有权限调用相应的函数
5. **Gas 费用**：transfer 操作需要支付 gas 费用

## 故障排除

### 如果函数调用失败
```bash
# 检查函数是否存在
sui client call --help

# 检查包是否正确发布
sui client objects --query-type package

# 检查对象是否存在
sui client objects
```

### 如果权限不足
```bash
# 检查当前地址
sui client active-address

# 检查对象所有者
sui client object <OBJECT_ID>
``` 
