extension HTMLDocument {
    public struct HTMLDocumentToSymbolCollectorAPI {
        public let _document: HTMLDocument 
        
        public init(
            document: HTMLDocument
        ) {
            self._document = document
        }

        public func document() -> HTMLSymbols {
            return HTMLSymbolCollector.collect(
                from: self._document.document_tree
            )
        }

        public func head() -> HTMLSymbols {
            return HTMLSymbolCollector.collect(
                from: _document.head
            )
        }

        public func body() -> HTMLSymbols {
            return HTMLSymbolCollector.collect(
                from: _document.body
            )
        }
    }

    public enum HTMLDocumentCollectionTargetAPI {
        case document
        case head
        case body
    }

    internal var collector: HTMLDocumentToSymbolCollectorAPI {
        return .init(document: self)
    }
    
    public func symbols(
        walk collection_target: HTMLDocumentCollectionTargetAPI = .document
    ) -> HTMLSymbols {
        switch collection_target {
        case .document:
            return collector.document()
        case .head:
            return collector.head()
        case .body:
            return collector.body()
        }
    }
}
