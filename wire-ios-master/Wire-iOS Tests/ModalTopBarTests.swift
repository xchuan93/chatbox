// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


@testable import Wire

class ModalTopBarTests: ZMSnapshotTestCase {
    
    var sut: ModalTopBar! = nil
    
    override func setUp() {
        super.setUp()
        sut = ModalTopBar()
    }
    
    func testThatItRendersCorrectly_ShortTitle() {
        sut.title = "Tim Cook"
        verifyInAllPhoneWidths(view: sut)
    }
    
    func testThatItRendersCorrectly_LongTitle() {
        sut.title = "Adrian Hardacre, Amelia Henderson & Dylan Parsons"
        verifyInAllPhoneWidths(view: sut)
    }
    
    func testThatItRendersCorrectly_ShortTitle_WithoutStatusBar() {
        sut = ModalTopBar(forUseWithStatusBar: false)
        sut.title = "Tim Cook"
        verifyInAllPhoneWidths(view: sut)
    }

    func testThatItRendersCorrectly_LongTitle_WithoutStatusBar() {
        sut = ModalTopBar(forUseWithStatusBar: false)
        sut.title = "Adrian Hardacre, Amelia Henderson & Dylan Parsons"
        verifyInAllPhoneWidths(view: sut)
    }
    
}
