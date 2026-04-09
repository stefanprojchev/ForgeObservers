/// Combine-like `.assign(to:on:)` for `AsyncSequence`, reducing ViewModel boilerplate.
extension AsyncSequence where Self: Sendable {
    /// Assigns each emitted element directly to a property on the given object.
    @MainActor
    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Element>,
        on object: Root
    ) async {
        do {
            for try await value in self where !Task.isCancelled {
                object[keyPath: keyPath] = value
            }
        } catch {}
    }

    /// Assigns each emitted element to a property after applying a transform.
    @MainActor
    func assign<Root: AnyObject, V>(
        to keyPath: ReferenceWritableKeyPath<Root, V>,
        on object: Root,
        transform: @Sendable @escaping (Element) -> V
    ) async {
        do {
            for try await value in self where !Task.isCancelled {
                object[keyPath: keyPath] = transform(value)
            }
        } catch {}
    }
}
