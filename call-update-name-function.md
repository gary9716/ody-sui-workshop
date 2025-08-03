# 使用 Sui CLI 调用 update_name 函数

## 模块信息

- **包名**: `lesson_1`
- **模块名**: `lesson_one::lesson_one`
- **发布地址**: `0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7`
- **函数**: `update_name(rookie: &mut Rookie, name: String)`

## 调用步骤

### 1. 首先部署包（如果还没有部署）

```bash
# 进入项目目录
cd lessons/lesson_1

# 构建包
sui move build

# 发布包
sui client publish --gas-budget 10000000
```

### 2. 创建一个 Rookie 对象（如果还没有）

```bash
# 调用 new_member 函数创建 Rookie
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function new_member \
  --args "Your Name" \
  --gas-budget 10000000
```

### 3. 调用 update_name 函数

```bash
# 基本调用格式
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_name \
  --args <ROOKIE_OBJECT_ID> "New Name" \
  --gas-budget 10000000
```

### 4. 实际示例

假设您有一个 Rookie 对象 ID 为 `0x123...`：

```bash
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_name \
  --args 0x1234567890abcdef "Alice Smith" \
  --gas-budget 10000000
```

## 查找 Rookie 对象 ID

### 方法 1: 查看您的对象

```bash
# 查看当前地址的所有对象
sui client objects

# 查找 Rookie 类型的对象
sui client objects | grep -i rookie
```

### 方法 2: 使用 Sui Explorer

1. 访问 https://suiexplorer.com/
2. 搜索您的地址
3. 查找类型为 `lesson_one::lesson_one::Rookie` 的对象

### 方法 3: 使用 Sui CLI 查询

```bash
# 查询特定类型的对象
sui client objects --query-type lesson_one::lesson_one::Rookie
```

## 完整的调用脚本

```bash
#!/bin/bash

# 设置变量
PACKAGE_ID="0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7"
MODULE="lesson_one"
FUNCTION="update_name"

echo "=== 调用 update_name 函数 ==="

# 1. 查找 Rookie 对象
echo "🔍 查找 Rookie 对象..."
ROOKIE_OBJECTS=$(sui client objects --query-type lesson_one::lesson_one::Rookie)

if [ -z "$ROOKIE_OBJECTS" ]; then
    echo "❌ 未找到 Rookie 对象"
    echo "请先调用 new_member 函数创建一个 Rookie 对象"
    exit 1
fi

echo "找到的 Rookie 对象："
echo "$ROOKIE_OBJECTS"

# 2. 获取第一个 Rookie 对象的 ID
ROOKIE_ID=$(echo "$ROOKIE_OBJECTS" | head -n 1 | awk '{print $1}')

echo ""
echo "使用对象 ID: $ROOKIE_ID"

# 3. 调用 update_name 函数
echo "🔄 调用 update_name 函数..."
sui client call \
  --package "$PACKAGE_ID" \
  --module "$MODULE" \
  --function "$FUNCTION" \
  --args "$ROOKIE_ID" "Updated Name" \
  --gas-budget 10000000

echo "✅ 调用完成！"
```

## 其他相关函数调用

### 调用 update_img_url 函数

```bash
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_img_url \
  --args <ROOKIE_OBJECT_ID> "https://example.com/image.jpg" \
  --gas-budget 10000000
```

### 调用 update_with_different_signer 函数

```bash
sui client call \
  --package 0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7 \
  --module lesson_one \
  --function update_with_different_signer \
  --args <ROOKIE_OBJECT_ID> \
  --gas-budget 10000000
```

## 故障排除

### 如果包未发布
```bash
# 检查包是否已发布
sui client objects --query-type package

# 如果未发布，先发布包
cd lessons/lesson_1
sui move build
sui client publish --gas-budget 10000000
```

### 如果找不到对象
```bash
# 检查所有对象
sui client objects

# 检查特定地址的对象
sui client objects --address <YOUR_ADDRESS>
```

### 如果调用失败
```bash
# 检查错误信息
sui client call --help

# 检查包和模块是否存在
sui client objects --query-type package | grep lesson_1
```

## 验证调用结果

调用成功后，您可以：

1. **查看交易详情**：
   ```bash
   sui client tx-block <TRANSACTION_ID>
   ```

2. **查看更新后的对象**：
   ```bash
   sui client object <ROOKIE_OBJECT_ID>
   ```

3. **在 Sui Explorer 中查看**：
   - 访问 https://suiexplorer.com/
   - 搜索您的交易 ID 或对象 ID 
