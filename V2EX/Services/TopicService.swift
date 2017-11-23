import Foundation
import Kanna

protocol TopicService: HTMLParseService {

    func homeNodes() -> [NodeModel]

    /// 获取 首页 数据
    ///
    /// - Parameters:
    ///   - success: 成功返回 nodes, topics, navigations
    ///   - failure: 失败
    func index(
        success: ((_ nodes: [NodeModel], _ topics: [TopicModel], _ rewardable: Bool) -> Void)?,
        failure: Failure?)

    /// 获取 最近 的分页数据
    ///
    /// - Parameters:
    ///   - success: 成功返回 topics
    ///   - failure: 失败
    func recentTopics(
        page: Int,
        success: ((_ topics: [TopicModel], _ maxPage: Int) -> Void)?,
        failure: Failure?)
    
    /// 获取 首页 主题数据
    ///
    /// - Parameters:
    ///   - href: href
    ///   - success: 成功返回 topics
    ///   - failure: 失败
    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?)

    /// 获取 主题 详情数据
    ///
    /// - Parameters:
    ///   - topic: topic
    ///   - success: 成功
    ///   - failure: 失败
    func topicDetail(
        topicID: String,
        success: ((_ topic: TopicModel, _ comments: [CommentModel], _ maxPage: Int) -> Void)?,
        failure: Failure?)

    /// 获取主题中更多评论
    ///
    /// - Parameters:
    ///   - topicID: 主题ID
    ///   - page: 获取页数
    ///   - success: 成功
    ///   - failure: 失败
    func topicMoreComment(
        topicID: String,
        page: Int,
        success: ((_ comments: [CommentModel]) -> Void)?,
        failure: Failure?)
    
    /// 发布评论
    ///
    /// - Parameters:
    ///   - once: 凭证
    ///   - topicID: 主题 id
    ///   - content: 回复内容
    ///   - success: 成功
    ///   - failure: 失败
    func comment(
        once: String,
        topicID: String,
        content: String,
        success: Action?,
        failure: Failure?)

    /// 上传图片到 SM.MS
    ///
    /// - Parameters:
    ///   - localURL: 图片本地URL
    ///   - success: 成功
    ///   - failure: 失败
    func uploadPicture(
        localURL: String,
        success: ((String) -> Void)?,
        failure: Failure?)

    /// 创建主题
    ///
    /// - Parameters:
    ///   - nodename: 节点名称
    ///   - title: 主题标题
    ///   - body: 主题正文
    ///   - success: 成功
    ///   - failure: 失败
    func createTopic(
        nodename: String,
        title: String,
        body: String?,
        success: Action?,
        failure: @escaping Failure)
    
    
    /// 搜索主题
    ///
    /// - Parameters:
    ///   - query: 关键字
    ///   - offset: 偏移量
    ///   - size: 一页大小
    ///   - sortType: 排序类型
    ///   - success: 成功
    ///   - failure: 失败
    func search(
        query: String,
        offset: Int,
        size: Int,
        sortType: SearchSortType,
        success: ((_ results: [SearchResultModel]) -> ())?,
        failure: Failure?)
    
    /// 忽略主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - once: 凭证
    ///   - success: 成功
    ///   - failure: 失败
    func ignoreTopic(topicID: String,
                     once: String,
                     success: Action?,
                     failure: Failure?)
    
    /// 收藏主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func favoriteTopic(topicID: String,
                       token: String,
                       success: Action?,
                       failure: Failure?)
    
    /// 取消收藏主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func unfavoriteTopic(topicID: String,
                         token: String,
                         success: Action?,
                         failure: Failure?)
    
    /// 感谢主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func thankTopic(topicID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?)
    
    /// 感谢回复
    ///
    /// - Parameters:
    ///   - replyID: 回复id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func thankReply(replyID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?)
}

extension TopicService {

    /// 首页节点
    /// 到时候会添加自定义节点的功能
    /// 所有暂时先这么做
    func homeNodes() -> [NodeModel] {
        var nodes = [
            NodeModel(title: "全部", href: "/?tab=all"),
            NodeModel(title: "最热", href: "/?tab=hot"),
            NodeModel(title: "技术", href: "/?tab=tech"),
            NodeModel(title: "创意", href: "/?tab=creative"),
            NodeModel(title: "好玩", href: "/?tab=play"),
            NodeModel(title: "Apple", href: "/?tab=apple"),
            NodeModel(title: "城市", href: "/?tab=city"),
            NodeModel(title: "问与答", href: "/?tab=qna"),
            NodeModel(title: "节点", href: "/?tab=nodes"),
            NodeModel(title: "R2", href: "/?tab=r2"),
            NodeModel(title: "交易", href: "/?tab=deals"),
            NodeModel(title: "酷工作", href: "/?tab=jobs")
        ]
        if AccountModel.isLogin {
            nodes.append(NodeModel(title: "关注", href: "/?tab=members"))
        }
        return nodes
    }
    
    func index(
        success: ((_ nodes: [NodeModel], _ topics: [TopicModel], _ rewardable: Bool) -> Void)?,
        failure: Failure?) {
        Networking.shared.htmlRequest(target: .topics(href: nil), success: { html in
            
            //            let nodePath = html.xpath("//*[@id='Wrapper']/div/div[3]/div[2]/a")
            
            // 有通知 代表登录成功
            var isLogin = false
            var rewardable = false
            if let innerHTML = html.innerHTML {
                isLogin = innerHTML.contains("notifications")
                if  isLogin {
                    // 领取今日登录奖励
                    if let dailyHref = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='inner']/a").first?["href"],
                        dailyHref == "/mission/daily" {
                        rewardable = true
                    }

                    if let account = self.parseLoginUser(html: html) {
                        account.save()
                    }
                } else {
                    AccountModel.delete()
                }
            }
            
            //  已登录 div[2] / 没登录 div[1]
            let nodePath = html.xpath("//*[@id='Wrapper']/div[@class='content']/div/div[\(isLogin ? 2 : 1)]/a")
            
            let nodes = nodePath.flatMap({ ele -> NodeModel? in
                guard let href = ele["href"],
                    let title = ele.content else {
                        return nil
                }
                let isCurrent = ele.className == "tab_current"
                
                return NodeModel(title: title, href: href, isCurrent: isCurrent)
            })
            
            let topics = self.parseTopic(html: html, type: .index)
            
            guard topics.count > 0 else {
                failure?("获取节点信息失败")
                return
            }
            
            success?(nodes, topics, rewardable)
        }, failure: failure)
    }

    func recentTopics(
        page: Int,
        success: ((_ topics: [TopicModel], _ maxPage: Int) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .recentTopics(page: page), success: { html in
            let topics = self.parseTopic(html: html, type: .index)
            let page = self.parsePage(html: html)
            success?(topics, page.max)
        }, failure: failure)

    }
    
    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        
        Network.htmlRequest(target: .topics(href: href), success: { html in
            let topics = self.parseTopic(html: html, type: .index)
            // Optimize: 区分数据解析失败 还是 没有数据
//            guard topics.count > 0 else {
//                failure?("获取节点信息失败")
//                return
//            }

            success?(topics)
        }, failure: failure)
    }

    func topicDetail(
        topicID: String,
        success: ((_ topic: TopicModel, _ comments: [CommentModel], _ maxPage: Int) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topicDetail(topicID: topicID, page: 1), success: { html in
            
            guard let _ = html.xpath("//*[@id='Wrapper']//div[@class='header']/small/text()[2]").first?.text else {
                // 需要登录
                if let error = html.xpath("//*[@id='Wrapper']/div[2]/div[2]").first?.content {
                    failure?(error)
                    return
                }
                // 需要验证
                if let error = html.xpath("//*[@id='Main']/div/div//span[@class='negative'][text()]").first?.content {
                    failure?("访问被限制节点的内容之前，你的账号需要完成以下验证：\n\(error)")
                    return
                }
                // 被重定向到首页, 无法查看, 先这样处理
                if html.title == "V2EX" {
                    failure?("无法查看该主题，被重定向到首页")
                    return
                }
                failure?("数据解析失败")
                return
            }
            
            let contentHTML = html.xpath("//*[@id='Wrapper']//div[@class='topic_content']").first?.toHTML ?? ""
            let subtleHTML = html.xpath("//*[@id='Wrapper']//div[@class='subtle']").flatMap { $0.toHTML }.joined(separator: "")
            let content = self.replacingIframe(text: contentHTML + subtleHTML)
            
            let comments = self.parseComment(html: html)

            guard let userPath = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='header']/div/a").first,
                let userAvatar = userPath.xpath("./img").first?["src"],
                let userhref = userPath["href"],
                let nodeEle = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='header']/a[2]").first,
                let nodeTitle = nodeEle.content,
                let nodeHref = nodeEle["href"],
                let title = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='header']/h1").first?.content else {
                    failure?("数据解析失败")
                    return
            }
            
            let member = MemberModel(username: userhref.lastPathComponent, url: userhref, avatar: userAvatar)
            let node = NodeModel(title: nodeTitle, href: nodeHref)
            var topic = TopicModel(member: member, node: node, title: title, href: "")
            
            // 获取 token
            if let csrfTokenPath = html.xpath("//*[@id='Wrapper']/div[@class='content']/div/div[@class='inner']//a[1]").first?["href"] {
                let csrfToken = URLComponents(string: csrfTokenPath)?["t"]
                let isFavorite = csrfTokenPath.hasPrefix("/unfavorite")
                topic.token = csrfToken

                // 如果是登录状态 检查是否已经感谢和收藏
                if AccountModel.isLogin {
                    topic.isFavorite = isFavorite
                    let thankStr = html.xpath("//*[@id='topic_thank']").first?.content ?? ""
                    topic.isThank = thankStr != "感谢"
                }
            }
            topic.lastReplyTime = html.xpath("//*[@id='Wrapper']/div[@class='content']/div[3]/div/span/text()").first?.content?.trimmed
            topic.once = self.parseOnce(html: html)
            topic.content = content
            topic.publicTime = html.xpath("//*[@id='Wrapper']/div/div[1]/div[1]/small/text()[2]").first?.content ?? ""
            let maxPage = html.xpath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[last()]/a[last()]").first?.content?.int ?? 1
            success?(topic, comments, maxPage)
        }, failure: failure)
    }


    func topicMoreComment(
        topicID: String,
        page: Int,
        success: ((_ comments: [CommentModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topicDetail(topicID: topicID, page: page), success: { html in
            let comments = self.parseComment(html: html)
            success?(comments)
        }, failure: failure)
    }


    func comment(
        once: String,
        topicID: String,
        content: String,
        success: Action?,
        failure: Failure?) {
        
        let params = [
            "content": content,
            "once": once
        ]
        
        Network.htmlRequest(target: .comment(topicID: topicID, dict: params), success: { html in
            guard let problem =  html.xpath("//*[@id='Wrapper']/div//div[@class='problem']/ul").first?.content else {
                success?()
                return
            }
            
            failure?(problem)
        }, failure: failure)
    }

    func uploadPicture(
        localURL: String,
        success: ((String) -> Void)?,
        failure: Failure?) {
        Network.request(target: .uploadPicture(localURL: localURL), success: { data in
            guard let resultDict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                failure?("上传失败")
                return
            }

            guard let dict = resultDict ,
            (dict["code"] as? String) == "success",
            let dataDict = dict["data"] as? [String: Any],
            let url = dataDict["url"] as? String else {
                failure?("上传失败")
                return
            }
            success?(url)
        }, failure: failure)
    }

    func createTopic(
        nodename: String,
        title: String,
        body: String?,
        success: Action?,
        failure: @escaping Failure) {
        
        Network.htmlRequest(target: .createTopic(nodename: nodename, dict: [:]), success: { html in
            guard let once = self.parseOnce(html: html) else {
                failure("无法授权失败")
                return
            }
            let params = [
                "title": title,
                "content": body ?? "",
                "once": once,
                "syntax": "1" //文本标记语法, 0: 默认 1: Markdown
            ]
            Network.htmlRequest(target: .createTopic(nodename: nodename, dict: params), success: { html in
                guard let problem =  html.xpath("//*[@id='Wrapper']/div//div[@class='problem']/ul").first?.content else {
                    success?()
                    return
                }
                failure(problem)
            }, failure: failure)
        }, failure: failure)
        
    }
    
    func search(
        query: String,
        offset: Int,
        size: Int,
        sortType: SearchSortType,
        success: ((_ results: [SearchResultModel]) -> ())?,
        failure: Failure?) {
        Network.request(target: .search(query: query, offset: offset, size: size, sortType: sortType.rawValue), success: { data in
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(SearchResponeModel.self, from: data),
                let result = response.result else {
                    failure?("搜索失败")
                    return
            }
            success?(result)
        }, failure: failure)
    }
    
    func ignoreTopic(topicID: String,
                     once: String,
                     success: Action?,
                     failure: Failure?) {
        Network.htmlRequest(target: .ignoreTopic(topicID: topicID, once: once), success: { html in
            success?()
        }, failure: failure)
    }
    
    func favoriteTopic(topicID: String,
                       token: String,
                       success: Action?,
                       failure: Failure?) {
        Network.htmlRequest(target: .favoriteTopic(topicID: topicID, token: token), success: { html in
            success?()
        }, failure: failure)
    }
    
    func unfavoriteTopic(topicID: String,
                         token: String,
                         success: Action?,
                         failure: Failure?) {
        Network.htmlRequest(target: .unfavoriteTopic(topicID: topicID, token: token), success: { html in
            success?()
        }, failure: failure)
    }
    
    func thankTopic(topicID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?) {
        Network.htmlRequestNotResponse(target: .thankTopic(topicID: topicID, token: token), success: {
            success?()
        }, failure: failure)
    }
    
    func thankReply(replyID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?) {
        Network.htmlRequestNotResponse(target: .thankReply(replyID: replyID, token: token), success: {
            success?()
        }, failure: failure)
    }
}
