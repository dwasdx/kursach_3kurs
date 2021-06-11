//
//  VisualSettingsView.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import SwiftUI

struct VisualSettingsView: View {
    @ObservedObject var viewModel = VisualSettingsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.items.indices) { index in
                let theme = viewModel.items[index]
                ThemeCell(theme: theme,
                          selectedTheme: $viewModel.selectedItem) { newTHeme in
                    viewModel.updateTheme(theme)
                }
//                HStack {
//                    Text(theme.description)
//                    Spacer()
//                    if viewModel.selectedItem == theme {
//                        Image(systemName: "checkmark")
//                            .foregroundColor(.blue)
//                    }
//                }
//                .onTapGesture(perform: {
//                    viewModel.updateTheme(theme)
//                })
            }
//            .navigationBarHidden(true)
//            .navigationBarTitle("Theme", displayMode: .inline)
//            Spacer()
        }
    }
}

fileprivate struct ThemeCell: View {
    
    var theme: Theme
    @Binding var selectedTheme: Theme
    var handler: ((Theme) -> Void) = {_ in }
    
    var body: some View {
        Button(action: {
            handler(theme)
        }, label: {
            HStack {
                Text(theme.description)
                Spacer()
                if theme == selectedTheme {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        })
//        .foregroundColor(Color.bl)
    }
}

struct VisualSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VisualSettingsView()
        ThemeCell(theme: .device, selectedTheme: .init(get: { .device }, set: {_ in }))
        ThemeCell(theme: .device, selectedTheme: .init(get: { .dark }, set: {_ in }))
    }
}
