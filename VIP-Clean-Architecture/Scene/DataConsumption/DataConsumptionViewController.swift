//
//  ViewController.swift
//  VIP-Clean-Architecture
//
//  Created by Ahil Ahilendran on 5/8/20.
//  Copyright © 2020 Ahil Ahilendran. All rights reserved.
//

import  UIKit

class DataConsumptionViewController: UIViewController {
    
    var output: DataConsumptionInteractorInput?
    var router: DataConsumptionRouterProtocol?
    
    var vmMain:[(title: String, vms: [DataConsumptionCellVM])] = []
    
    let tableView = UITableView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // MARK: - Configurator
    private func configure(configurator: NSBaseConfig = PCRHomeConfigurator.sharedInstance) {
        configurator.configure(viewController: self)
    }
    
    
    override func viewDidLoad() {
        setupViews()
        output?.getMobileDataConsumption()
    }
    
    
    func setupViews() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.fill(view)
        setupTableView()
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 319
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.backgroundColor = .lightGray
        tableView.register(DataConsumptionViewHeader.self, forHeaderFooterViewReuseIdentifier: DataConsumptionViewHeader.reuseIdentifier)
        tableView.register(DataConsumptionCell.self, forCellReuseIdentifier: DataConsumptionCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }
}

extension DataConsumptionViewController: DataConsumptionPresenterOutput {
    func displayDataConsumptionList(vm: [(title: String, vms: [DataConsumptionCellVM])]) {
        vmMain = vm
        reloadTableView()
    }
    
    func displayErrorMessage(message: String) {
        
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
}

extension DataConsumptionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vmMain.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DataConsumptionViewHeader.reuseIdentifier) as? DataConsumptionViewHeader else { return UIView()}
        header.vm = vmMain[safe: section]?.title
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmMain[safe: section]?.vms.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataConsumptionCell.reuseIdentifier, for: indexPath) as? DataConsumptionCell else { return UITableViewCell() }
        cell.cellVM = vmMain[safe: indexPath.section]?.vms[safe: indexPath.row]
        cell.delegate = self
        return cell
    }
    
    
}

extension DataConsumptionViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let loadCellIndexPath =  tableView.indexPathsForVisibleRows?.last {
            if isLastCell(for: loadCellIndexPath) {
                output?.getMobileDataConsumption()
            }
        }
    }
    
    //TODOA
    func isLastCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >=  (vmMain.last?.vms.count ?? 1) - 1
    }
}

extension DataConsumptionViewController: DataConsumptionCellDelagate {
    func downButtonTapped() {
       debugPrint("tapped")
    }
    
    
}
