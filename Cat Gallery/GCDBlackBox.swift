//
//  GCDBlackBox.swift
//  Cat Gallery
//
//  Created by Steven Hurtado on 12/7/16.
//  Copyright © 2016 Steven Hurtado. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void)
{
    DispatchQueue.main.async
    {
        updates()
    }
}
