# Beaver Planner - Design System
## 河狸日程设计规范

### 色彩系统

```css
:root {
  --beaver-brown: #8B5A2B;
  --lake-blue: #5B9BD5;
  --wood-yellow: #D4A574;
  --moss-green: #7A9E7E;
  --autumn-orange: #E07A5F;
  --wood-light: #F5F1E8;
  --text-dark: #3D2914;
  --text-light: #8B7355;
}
```

### 字体规范

- **标题**: SF Pro Display Bold
- **正文**: SF Pro Text Regular
- **数字**: SF Mono (时间显示)

### 图标尺寸

- App Icon: 1024×1024px
- Tab Bar: 25×25pt
- Toolbar: 22×22pt

### 间距系统

基于 8pt 网格：
- xs: 4pt
- sm: 8pt
- md: 16pt
- lg: 24pt
- xl: 32pt
- xxl: 48pt

### 圆角规范

- 卡片: 12pt
- 按钮: 8pt
- 输入框: 8pt
- 全圆角: 50%

### 阴影层级

```css
.shadow-sm: 0 1px 2px rgba(61, 41, 20, 0.05);
.shadow-md: 0 4px 6px rgba(61, 41, 20, 0.07);
.shadow-lg: 0 10px 15px rgba(61, 41, 20, 0.1);
```

### 动画时长

- 微交互: 150ms
- 标准: 300ms
- 复杂动画: 500ms
- 缓动函数: ease-out

### 河狸助手对话规范

- 气泡最大宽度: 280pt
- 头像尺寸: 40×40pt
- 内边距: 12pt
- 圆角: 16pt (左下直角)

### 时间块规范

- 最小高度: 60pt (1小时)
- 左右边距: 16pt
- 块间距: 4pt
- 完成状态: 100% 木头黄填充
