//
//  DropDownStorageOptionView.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 11/5/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import UIKit

//MARK: drop down title view
class DropDownStorageOptionView: UIView {
    
    //var dropDownView = DropDownStorageOptionTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addSubview(viewText)
        self.addSubview(downArrow)
        self.addSubview(upArrow)
        
        viewText.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        viewText.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -22).isActive = true
        viewText.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        viewText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        downArrow.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        downArrow.widthAnchor.constraint(equalToConstant: 16).isActive = true
        downArrow.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        downArrow.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        upArrow.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        upArrow.widthAnchor.constraint(equalToConstant: 16).isActive = true
        upArrow.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        upArrow.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        upArrow.isHidden = true
        downArrow.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    //MARK: title view components
    var viewText: UILabel = {
        var textLabel = UILabel()
        textLabel.font = UIFont(name: "Headline", size: 16)
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    var downArrow: UILabel = {
        var arrow = UILabel.labelWithIonicon(.AndroidArrowDropdown, color: .defaultTint, iconSize: 24)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        return arrow
    }()
    
    var upArrow: UILabel = {
        var arrow = UILabel.labelWithIonicon(.AndroidArrowDropup, color: .defaultTint, iconSize: 24)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        return arrow
    }()
    
    //MARK: arrow directions
    enum arrowDirection {
        case down
        case up
    }
    
    func changeArrowDirection(direction: arrowDirection){
        switch direction{
        case .down:
            upArrow.isHidden = true
            downArrow.isHidden = false
            break
        case .up:
            upArrow.isHidden = false
            downArrow.isHidden = true
            break
        }
    }
}

//MARK: Drop down protocol
protocol DropDownProtocol {
    func dropDownPressed(string: String)
}


//MARK: Drop Down table view
class DropDownStorageOptionTableView: UIView, UITableViewDelegate, UITableViewDataSource {

    var dropDownOptions = [String]()
    var tableView = UITableView()
    var delegate: DropDownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        self.backgroundColor = UIColor.lightGray
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        if #available(iOS 13.0, *) {
            cell.textLabel?.textColor = UIColor.dynamicTextColor
            cell.backgroundColor = UIColor.dynamicBackgroundColor
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        }
        cell.textLabel?.textAlignment = .center
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
