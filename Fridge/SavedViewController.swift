//
//  SavedViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/01.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import NCMB

class SavedViewController: TabmanViewController {

    private var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        // create bar
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.layout.contentMode = .fit
        bar.buttons.customize { (button) in
            button.tintColor = .lightGray
            button.selectedTintColor = UIColor(red: 0.00, green: 0.91, blue: 0.80, alpha: 1.00)
        }
        bar.backgroundColor = .white
        bar.indicator.tintColor = UIColor(red: 0.22, green: 0.98, blue: 0.85, alpha: 1.00)
        addBar(bar, dataSource: self, at: .top)
    }

    private func setTabControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController1 = storyboard.instantiateViewController(withIdentifier: "SavedRecipeViewController")
        let viewController2 = storyboard.instantiateViewController(withIdentifier: "SelfRecipeViewController")
        
        viewControllers = [viewController1, viewController2]
    }
    
}

extension SavedViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        //print(viewControllers.count)
        
        setTabControllers()
        
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let titleName = ["保存済みレシピ","自分のレシピ"]
        var items = [TMBarItem]()
        
        for i in titleName {
            let title = TMBarItem(title: i)
            items.append(title)
        }
        
        return items[index]
    }
}

