#!/bin/bash

echo "=== 调用包含 Transfer 的函数 ==="

# 设置变量
PACKAGE_ID="0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7"
MODULE="lesson_one"
FUNCTION="new_member"

echo "📋 包信息："
echo "- 包 ID: $PACKAGE_ID"
echo "- 模块: $MODULE"
echo "- 函数: $FUNCTION (包含 transfer::public_transfer 操作)"

echo ""
echo "🔍 步骤 1: 检查包是否已发布..."
PACKAGE_EXISTS=$(sui client objects --query-type package | grep "$PACKAGE_ID")

if [ -z "$PACKAGE_EXISTS" ]; then
    echo "❌ 包未发布，正在发布包..."
    cd lessons/lesson_1
    sui move build
    sui client publish --gas-budget 10000000
    cd ../..
    echo "✅ 包已发布"
else
    echo "✅ 包已发布"
fi

echo ""
echo "🔍 步骤 2: 检查当前对象..."
echo "当前 Rookie 对象："
sui client objects --query-type lesson_one::lesson_one::Rookie 2>/dev/null || echo "未找到 Rookie 对象"

echo ""
echo "🔄 步骤 3: 调用包含 transfer 的函数..."
read -p "请输入新成员名称: " NAME

if [ -z "$NAME" ]; then
    NAME="Test Member"
    echo "使用默认名称: $NAME"
fi

echo ""
echo "🎯 调用参数："
echo "- 函数: $FUNCTION"
echo "- 参数: \"$NAME\""
echo "- Gas 预算: 10000000"

# 调用函数
echo ""
echo "🔄 正在调用函数..."
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
    echo "新创建的 Rookie 对象："
    sui client objects --query-type lesson_one::lesson_one::Rookie
    
    echo ""
    echo "🎉 Transfer 操作完成！"
    echo "新对象已 transfer 到您的地址"
else
    echo "❌ 调用失败"
    echo ""
    echo "💡 故障排除："
    echo "1. 检查包是否正确发布"
    echo "2. 检查网络连接"
    echo "3. 检查 gas 余额"
    echo "4. 查看详细错误信息"
fi

echo ""
echo "💡 其他有用的命令："
echo "- 查看所有对象: sui client objects"
echo "- 查看交易历史: sui client tx-block <TRANSACTION_ID>"
echo "- 查看对象详情: sui client object <OBJECT_ID>"
echo "- 查看余额: sui client balance" 
