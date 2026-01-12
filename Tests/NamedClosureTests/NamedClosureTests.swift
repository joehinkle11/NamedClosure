import Testing
import NamedClosure

@Test func `named closure to global function`() {
    var didCallFreeFunc = false
    func freeFunction() {
        didCallFreeFunc = true
    }
    #expect(didCallFreeFunc == false)
    let namedClosure = #namedClosure(freeFunction())
    #expect(namedClosure.type == nil)
    #expect(namedClosure.name == "freeFunction")
    let returnedValue: () = namedClosure.call()
    #expect(returnedValue == ())
    #expect(didCallFreeFunc == true)
}

@Test func `named closure to class method`() {
    class C {
        var didCallM = false
        func m() {
            didCallM = true
        }
    }
    let c = C()
    #expect(c.didCallM == false)
    let namedClosure = #namedClosure(c.m())
    #expect(namedClosure.type == C.self)
    #expect(namedClosure.name == "m")
    let returnedValue: () = namedClosure.call()
    #expect(returnedValue == ())
    #expect(c.didCallM == true)
}


@Test func `returnedValue as Int`() {
    func freeFunction() -> Int {
        return 5
    }
    let namedClosure = #namedClosure(freeFunction())
    let returnedValue: Int = namedClosure.call()
    #expect(returnedValue == 5)
}
