# v0.2.0 发布包审计

本地包为 _build/publish/jojochensmart-lab-moonpicross-0.2.0.zip。moon package --list 输出 43 个文件。CRC 全部通过，SHA256 为 e91d3cbae4d9c795de3921077f2af4d8e7989b37e757bbf091ea35bbd7c954c0。

自动检查路径安全、唯一条目、允许的目录与扩展名，并扫描文本中的本机路径、手机号和常见凭据格式。扫描器源码的测试模式本身跳过模式扫描。归档不含申报书、构建产物、生成的接口快照、Studio 或 GitHub 工作流。未检出上述敏感内容。包内 README、LICENSE 和 moon.mod 逐字节匹配当前项目文件，仓库 URL、模块名、Apache-2.0 和 0.2.0 核对通过。模式检测作为重复检查，不能证明识别任意形式的秘密。

解包后在全新目录创建消费项目，moon.work 的库成员只指向解包目录。独立消费项目 check 通过，Wasm GC 和 JS 均通过 JSON v1 导入、求解、唯一性、固定种子生成和 Budget 断言。局部接口快照对照 v0.1.0，唯一差异为新增 solve_bounded，原有公开记录、签名、默认参数和错误类型一致。原求解、生成示例继续通过。搜索轨迹、首解顺序、难度和固定种子输出可能随版本变化。无正式发布操作。
