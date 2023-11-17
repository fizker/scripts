# Snippets for Xcode


## Tests


### Test class

Proper test class

| Language | Platform | Completion | Availability |
| -------- | -------- | ---------- | ------------ |
| Swift | All | test | Top Level |

```swift
import XCTest
/*@START_MENU_TOKEN@*/@testable /*@END_MENU_TOKEN@*/import <#Subject module#>

final class <#TestSubject#>Tests: XCTestCase {
	/*@START_MENU_TOKEN@*//*Body*//*@END_MENU_TOKEN@*/
}
```


### Test func

Proper test func

| Language | Platform | Completion | Availability |
| -------- | -------- | ---------- | ------------ |
| Swift | All | test | Class Implementation |

```swift
func test__<#UnitUnderTest#>__<#context#>__<#expectedResult#>() async throws {
		/*@START_MENU_TOKEN@*/throw XCTSkip("Not implemented")/*@END_MENU_TOKEN@*/
	}
```
