import Foundation
import CoreData


class Revision: NSManagedObject {
    @NSManaged var siteId: NSNumber
    @NSManaged var revisionId: NSNumber
    @NSManaged var postId: NSNumber

    @NSManaged var postAuthorId: NSNumber?

    @NSManaged var postTitle: String?
    @NSManaged var postContent: String?
    @NSManaged var postExcerpt: String?

    @NSManaged var postDateGmt: String?
    @NSManaged var postModifiedGmt: String?

    @NSManaged var diff: RevisionDiff?
}
