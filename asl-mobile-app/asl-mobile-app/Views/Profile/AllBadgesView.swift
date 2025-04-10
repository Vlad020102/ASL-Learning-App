//
//  AllBadgesView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone"
//

import SwiftUI

struct AllBadgesView: View {
    let badges: [Badge]
    
    var body: some View {
        ScrollView {
            BadgesView(badges: badges, title: "All Badges")
                .background(Color.clear)
                .padding()
        }
        .navigationTitle("All Badges")
        .background(AppColors.background)
    }
}

struct AllBadgesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllBadgesView(badges: [])
        }
    }
}
