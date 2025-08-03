# 使用 Sui CLI 调用 upgrade 函数

## 函数签名

```move
public fun upgrade(rookie: Rookie, clock: &Clock, ctx: &mut TxContext)
```

## 参数说明

- **`rookie: Rookie`** - 要升级的 Rookie 对象
- **`clock: &Clock`** - 时钟对象（用于获取时间戳）
- **`ctx: &mut TxContext`** - 交易上下文

## 升级条件

在调用 `upgrade` 之前，必须满足以下条件：

1. **`signer.is_some()`** - 必须有签名者
2. **`ctx.sender() == creator`** - 必须是创建者调用
3. **`!img_url.is_empty()`** - 图片URL不能为空
4. **`!name.is_empty()`** - 名称不能为空

## 调用步骤

### 步骤 1: 创建 Rookie 对象

```bash
# 调用 new_member 创建 Rookie
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function new_member \
  --args "Initial Name" \
  --gas-budget 10000000
```

### 步骤 2: 更新 Rookie 信息

```bash
# 更新名称
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_name \
  --args <ROOKIE_OBJECT_ID> "Final Name" \
  --gas-budget 10000000

# 更新图片URL
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_img_url \
  --args <ROOKIE_OBJECT_ID> "https://example.com/image.jpg" \
  --gas-budget 10000000
```

### 步骤 3: 设置签名者

```bash
# 使用不同地址设置签名者
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_with_different_signer \
  --args <ROOKIE_OBJECT_ID> \
  --gas-budget 10000000
```

### 步骤 4: 调用 upgrade 函数

```bash
# 调用 upgrade 函数
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function upgrade \
  --args <ROOKIE_OBJECT_ID> <CLOCK_OBJECT_ID> \
  --gas-budget 10000000
```

## 获取 Clock 对象

Clock 对象是 Sui 系统提供的共享对象：

```bash
# 获取 Clock 对象 ID
sui client objects --query-type 0x2::clock::Clock
```

通常 Clock 对象的 ID 是：`0x6`

## 完整的升级脚本

```bash
#!/bin/bash

echo "=== 升级 Rookie 到 Member ==="

# 设置变量
PACKAGE_ID="0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7"
MODULE="lesson_one"
CLOCK_ID="0x6"

echo "📋 包信息："
echo "- 包 ID: $PACKAGE_ID"
echo "- 模块: $MODULE"
echo "- Clock ID: $CLOCK_ID"

echo ""
echo "🔍 步骤 1: 查找 Rookie 对象..."
ROOKIE_OBJECTS=$(sui client objects --query-type lesson_one::lesson_one::Rookie 2>/dev/null)

if [ -z "$ROOKIE_OBJECTS" ]; then
    echo "❌ 未找到 Rookie 对象，正在创建..."
    
    # 创建 Rookie 对象
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function new_member \
      --args "Test User" \
      --gas-budget 10000000
    
    # 重新查找
    ROOKIE_OBJECTS=$(sui client objects --query-type lesson_one::lesson_one::Rookie 2>/dev/null)
fi

if [ -n "$ROOKIE_OBJECTS" ]; then
    echo "✅ 找到 Rookie 对象："
    echo "$ROOKIE_OBJECTS"
    
    # 获取第一个 Rookie 对象 ID
    ROOKIE_ID=$(echo "$ROOKIE_OBJECTS" | head -n 1 | awk '{print $1}')
    
    echo ""
    echo "🎯 使用对象 ID: $ROOKIE_ID"
    
    echo ""
    echo "🔄 步骤 2: 更新 Rookie 信息..."
    
    # 更新名称
    read -p "请输入新名称: " NEW_NAME
    if [ -z "$NEW_NAME" ]; then
        NEW_NAME="Upgraded User"
    fi
    
    echo "更新名称..."
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function update_name \
      --args "$ROOKIE_ID" "$NEW_NAME" \
      --gas-budget 10000000
    
    # 更新图片URL
    read -p "请输入图片URL: " IMG_URL
    if [ -z "$IMG_URL" ]; then
        IMG_URL="https://example.com/image.jpg"
    fi
    
    echo "更新图片URL..."
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function update_img_url \
      --args "$ROOKIE_ID" "$IMG_URL" \
      --gas-budget 10000000
    
    echo ""
    echo "🔄 步骤 3: 设置签名者..."
    echo "设置签名者..."
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function update_with_different_signer \
      --args "$ROOKIE_ID" \
      --gas-budget 10000000
    
    echo ""
    echo "🔄 步骤 4: 调用 upgrade 函数..."
    echo "升级 Rookie 到 Member..."
    
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function upgrade \
      --args "$ROOKIE_ID" "$CLOCK_ID" \
      --gas-budget 10000000
    
    if [ $? -eq 0 ]; then
        echo "✅ 升级成功！"
        echo ""
        echo "📋 验证结果："
        echo "查看新创建的 Member 对象："
        sui client objects --query-type lesson_one::lesson_one::Member
    else
        echo "❌ 升级失败"
        echo ""
        echo "💡 可能的原因："
        echo "1. 不满足升级条件"
        echo "2. 权限不足"
        echo "3. 对象状态不正确"
    fi
else
    echo "❌ 无法找到或创建 Rookie 对象"
    exit 1
fi
```

## 验证升级结果

### 检查 Member 对象

```bash
# 查看 Member 对象
sui client objects --query-type lesson_one::lesson_one::Member
```

### 检查事件

```bash
# 查看交易详情（包含事件）
sui client tx-block <TRANSACTION_ID>
```

## 故障排除

### 如果升级失败

1. **检查条件**：
   ```bash
   # 查看 Rookie 对象详情
   sui client object <ROOKIE_OBJECT_ID>
   ```

2. **检查权限**：
   ```bash
   # 确认当前地址是创建者
   sui client active-address
   ```

3. **检查字段**：
   - 确保 `name` 不为空
   - 确保 `img_url` 不为空
   - 确保 `signer` 已设置

### 常见错误

- **`ENotUpgradeable`**：不满足升级条件
- **`EIsOwner`**：权限不足
- **对象不存在**：Rookie 对象已被删除或转移

## 注意事项

1. **不可逆操作**：升级后 Rookie 对象会被删除
2. **权限要求**：只有创建者可以升级
3. **数据完整性**：必须填写完整信息才能升级
4. **事件记录**：升级会触发 `MemberRegisterEvent` 事件 
