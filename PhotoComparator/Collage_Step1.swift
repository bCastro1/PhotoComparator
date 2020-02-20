//
//  Collage_Step1.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/31/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class Collage_Step1: CollectionViewController {

    //MARK:Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.title = "Choose Layout"
        
        self.populateLayoutArrays()

    }
    
    //MARK: SetupCells
    func populateLayoutArrays(){
        let grid = Grid(columns: 2, margin: UIEdgeInsets(all: 8), padding: .zero)

        let layout_2 = [
            CollageLayoutModel(name: "Side by Side", image: "2a", image_blank: "2a_b"),
            CollageLayoutModel(name: "Stacked", image: "2b", image_blank: "2b_b")
        ]
        let header2 = HeaderViewModel(.init(title: "2 Photo Layouts"))
        let layout_2_Items = layout_2.map { [weak self] layout_2 in
            CollageLayoutViewModel(layout_2)
            .onSelect { [weak self] viewModel in
                self!.pushToCollageStep2(layoutChosen: viewModel.model)
                print("img: \(viewModel.model.image)")
            }
        }
        let layout_2_Section = Section(grid: grid, header: header2, footer: nil, items: layout_2_Items)
        
        let layout_3 = [
            CollageLayoutModel(name: "2 Together, 1 Long", image: "3a", image_blank: "3a_b"),
            CollageLayoutModel(name: "1 Big, 2 Small", image: "3b", image_blank: "3b_b"),
            CollageLayoutModel(name: "3 Thin Vertical", image: "3c", image_blank: "3c_b"),
            CollageLayoutModel(name: "3 Thin Stacked", image: "3d", image_blank: "3d_b")
        ]
        let header3 = HeaderViewModel(.init(title: "3 Photo Layouts"))
        let layout_3_Items = layout_3.map { [weak self] layout_3 in
            CollageLayoutViewModel(layout_3)
            .onSelect { [weak self] viewModel in
                self!.pushToCollageStep2(layoutChosen: viewModel.model)
                print("img: \(viewModel.model.image)")
            }
        }
        let layout_3_Section = Section(grid: grid, header: header3, footer: nil, items: layout_3_Items)

        
        let layout_4 = [
            CollageLayoutModel(name: "4 Corners", image: "4a", image_blank: "4a_b"),
            CollageLayoutModel(name: "3 Vertical Thin, 1 Stacked", image: "4b", image_blank: "4b_b"),
            CollageLayoutModel(name: "3 Thumbnails, 1 Stacked", image: "4c", image_blank: "4c_b"),
            CollageLayoutModel(name: "3 Thumbnails, 1 Side Display", image: "4d", image_blank: "4d_b")
        ]
        let header4 = HeaderViewModel(.init(title: "4 Photo Layouts"))
        let layout_4_Items = layout_4.map { [weak self] layout_4 in
            CollageLayoutViewModel(layout_4)
            .onSelect { [weak self] viewModel in
                self!.pushToCollageStep2(layoutChosen: viewModel.model)
                print("img: \(viewModel.model.image)")
            }
        }
        let layout_4_Section = Section(grid: grid, header: header4, footer: nil, items: layout_4_Items)

        self.collectionView.source = .init(grid: grid, sections: [layout_2_Section, layout_3_Section, layout_4_Section])
        self.collectionView.reloadData()
    }

    //MARK: step 2 push
    func pushToCollageStep2(layoutChosen: CollageLayoutModel){
        let collageStep2 = Collage_Step2(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!, layoutModel: layoutChosen)
        collageStep2.modalPresentationStyle = .fullScreen
        collageStep2.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(collageStep2, animated: true)
    }
}
