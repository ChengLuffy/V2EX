import Foundation
import Kanna

protocol NodeService: HTMLParseService {
    
    /// 获取节点导航
    ///
    /// - Parameters:
    ///   - success: 成功
    ///   - failure: 失败
    func nodeNavigation(
        success: ((_ nodeCategorys: [NodeCategoryModel]) -> Void)?,
        failure: Failure?)
    
    
    /// 获取指定节点的详情和主题
    ///
    /// - Parameters:
    ///   - node: node
    ///   - success: 成功
    ///   - failure: 失败
    func nodeDetail(
        page: Int,
        node: NodeModel,
        success: ((_ node: NodeModel, _ topics: [TopicModel], _ maxPage: Int) -> Void)?,
        failure: Failure?)
    
    
    /// 获取我收藏的节点
    ///
    /// - Parameters:
    ///   - success: 成功
    ///   - failure: 失败
    func myNodes(
        success: ((_ nodes: [NodeModel]) -> Void)?,
        failure: Failure?)
    
    /// 所有节点
    ///
    /// - Parameters:
    ///   - success: 成功
    ///   - failure: 失败
    func nodes(
        success: @escaping ((_ groups: [NodeCategoryModel]) -> Void),
        failure: Failure?)
}

extension NodeService {
    
    func nodeNavigation(
        success: ((_ nodeCategorys: [NodeCategoryModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .topics(href: nil), success: { html in
            let cates = self.parseNodeNavigation(html: html)
            success?(cates)
        }, failure: failure)
    }
    
    
    func nodeDetail(
        page: Int,
        node: NodeModel,
        success: ((_ node: NodeModel, _ topics: [TopicModel], _ maxPage: Int) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .nodeDetail(href: node.path, page: page), success: { html in
            
            //            let nodeIcon = html.xpath("//*[@id='Main']//div[@class='header']/div/img").first?["src"]
            //            let nodeIntro = html.xpath("//*[@id='Main']//div[@class='header']/span[last()]").first?.content
            //            let topicNumber = html.xpath("//*[@id='Main']//div[@class='header']/div[2]/strong").first?.content
            //            var `node` = node
            //            node.icon = nodeIcon
            //            node.intro = nodeIntro
            //            node.topicNumber = topicNumber
            
            var `node` = node
            if let title = html.xpath("//*[@id='Wrapper']//div[@class='header']/text()[2]").first?.text?.trimmed {
                node.title = title
            }
            node.favoriteHref = html.xpath("//*[@id='Wrapper']//div[@class='header']/div/a").first?["href"]
            node.isFavorite = node.favoriteHref?.hasPrefix("/unfavorite") ?? false
            let topics = self.parseTopic(html: html, type: .nodeDetail)
            let page = self.parsePage(html: html).max

            // 如果主题数量 == 0， 并且 title == 登录， 代表该节点需要登录才能查看
            if !topics.count.boolValue, node.title == "登录" {
                failure?("查看该节点需要先登录")
                return
            }
            success?(node, topics, page)
        }, failure: failure)
    }
    
    func myNodes(
        success: ((_ nodes: [NodeModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .myNodes, success: { html in
            let nodes = html.xpath("//*[@id='MyNodes']/a/div").flatMap({ (ele) -> NodeModel? in
                guard let imageSrc = ele.xpath("./img").first?["src"],
                    let comment = ele.xpath("./span").first?.content,
                    let title = ele.parent?.xpath("./div/text()").first?.content,
                    let href = ele.parent?["href"] else {
                        return nil
                }
                return NodeModel(title: title, href: href, icon: imageSrc, comments: comment)
            })
            success?(nodes)
        }, failure: failure)
    }
    
    func nodes(
        success: @escaping ((_ groups: [NodeCategoryModel]) -> Void),
        failure: Failure?) {

        if let groups = NodeCategoryModel.get() {
            success(groups)
            return
        }

        Network.request(target: .nodes, success: { data in
            guard let nodes = NodeModel.nodes(data: data) else {
                failure?("数据解析失败")
                return
            }
            self.nodeSort(nodes, complete: success)
        }, failure: failure)
//        Network.htmlRequest(target: .nodes, success: { html in
//            let nodesPath = html.xpath("//*[@id='Wrapper']/div/div[@class='box']/div[@class='inner']/a")
//            let nodes = nodesPath.flatMap({ ele -> NodeModel? in
//                guard let nodename = ele.content,
//                    let nodeHref = ele["href"] else {
//                        return nil
//                }
//                return NodeModel(name: nodename, href: nodeHref)
//            })
//            success?(nodes)
//        }, failure: failure)
    }
    
    
    /// 将所有 node 排序成组
    ///
    /// - Parameters:
    ///   - nodes: nodes
    ///   - complete: 完成
    private func nodeSort(_ nodes: [NodeModel], complete: @escaping ((_ nodeGroup: [NodeCategoryModel]) -> Void )) {
        guard nodes.count > 0 else { return }

        GCD.runOnBackgroundThread {

            var `nodes` = nodes

            let tempInitial = nodes[0].title.pinYingString.firstLetter
            let currentGroup = NodeCategoryModel(id: 0, name: tempInitial, nodes: [])
            var group: [NodeCategoryModel] = [currentGroup]

            var otherGroup = NodeCategoryModel(id: 0, name: "#", nodes: [])

            for node in nodes {
                let initial = node.title.pinYingString.firstLetter

                //  不放在其他组, 单独一组
                if initial != "", !initial.isLetter() {
                    otherGroup.nodes.append(node)
                    continue
                }

                if let index = group.index(where: { $0.name == initial }) {
                    group[index].nodes.append(node)
                    continue
                }

                group.append(NodeCategoryModel(id: 0, name: initial, nodes: [node]))
            }

            if otherGroup.nodes.count.boolValue {
                group.append(otherGroup)
            }

            group.sort { (lhs, rhs) -> Bool in
                return lhs.name < rhs.name
            }

            // 缓存排序后的数据
            NodeCategoryModel.save(group)

            GCD.runOnMainThread {
                complete(group)
            }
        }
    }
    

}
