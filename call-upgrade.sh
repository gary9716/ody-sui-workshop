#!/bin/bash

echo "=== 调用 upgrade 函数 ==="

# 设置变量
PACKAGE_ID="0xd1f32dfb749c3008c4078c4824dde1a8944b5bd75e62852c717e261304572ff7"
MODULE="lesson_one"
CLOCK_ID="0x6"

echo "📋 包信息："
echo "- 包 ID: $PACKAGE_ID"
echo "- 模块: $MODULE"
echo "- Clock ID: $CLOCK_ID"

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
echo "🔍 步骤 2: 查找 Rookie 对象..."
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
    
    echo "✅ Rookie 对象已创建"
    
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
    echo "🔄 步骤 3: 更新 Rookie 信息..."
    
    # 更新名称
    read -p "请输入新名称 (默认: Upgraded User): " NEW_NAME
    if [ -z "$NEW_NAME" ]; then
        NEW_NAME="Upgraded User"
    fi
    
    echo "更新名称: $NEW_NAME"
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function update_name \
      --args "$ROOKIE_ID" "$NEW_NAME" \
      --gas-budget 10000000
    
    # 更新图片URL
    read -p "请输入图片URL (默认: https://example.com/image.jpg): " IMG_URL
    if [ -z "$IMG_URL" ]; then
        IMG_URL="https://example.com/image.jpg"
    fi
    
    echo "更新图片URL: $IMG_URL"
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function update_img_url \
      --args "$ROOKIE_ID" "$IMG_URL" \
      --gas-budget 10000000
    
    echo ""
    echo "🔄 步骤 4: 设置签名者..."
    echo "设置签名者..."
    sui client call \
      --package "$PACKAGE_ID" \
      --module "$MODULE" \
      --function update_with_different_signer \
      --args "$ROOKIE_ID" \
      --gas-budget 10000000
    
    echo ""
    echo "🔄 步骤 5: 调用 upgrade 函数..."
    echo "升级 Rookie 到 Member..."
    echo "参数: $ROOKIE_ID, $CLOCK_ID"
    
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
        
        echo ""
        echo "🎉 升级完成！"
        echo "- Rookie 对象已被删除"
        echo "- Member 对象已创建"
        echo "- 事件已触发"
    else
        echo "❌ 升级失败"
        echo ""
        echo "💡 可能的原因："
        echo "1. 不满足升级条件 (signer.is_some() && ctx.sender() == creator && !img_url.is_empty() && !name.is_empty())"
        echo "2. 权限不足 (必须是创建者)"
        echo "3. 对象状态不正确"
        echo "4. Clock 对象不存在"
    fi
else
    echo "❌ 无法找到或创建 Rookie 对象"
    exit 1
fi

echo ""
echo "💡 其他有用的命令："
echo "- 查看所有对象: sui client objects"
echo "- 查看交易历史: sui client tx-block <TRANSACTION_ID>"
echo "- 查看对象详情: sui client object <OBJECT_ID>"
echo "- 查看余额: sui client balance" 
